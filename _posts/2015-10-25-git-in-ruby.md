---
title:  Implementing Git in Ruby
author: Dave Kinkead
layout: post
status: forthcoming
meetup: Oct 2015
---

# Git in Ruby

Learning the fundamentals of anything is critical to understanding it but I found git extra hard because the most common commands - the porcelain - are conceptually very different to the data model - the plumbing.

But Git doesn't have to be hard.  In this talk, I show how Git works under the hood by implementing it from scratch in Ruby.

---

## Git can be scary.

How people are exposed to Git, and Git's inconsistent naming, makes understanding it hard.

But Git is quite simple.  Kind of.

To show just how easy it is, we'll implement Git in Ruby.

---

## Content Addressable Storage

The first problem is that most people think of Git as Version Control Software.

It is, but don't do that.  Instead, think of Git the way it was designed.

Git is Content Addressable Storage.

---

## Cryptographic Hashes

Content Addressable Storage is based on crytographic hashes.

A hash (or digest) is just a mathematical that takes content - strings or bytes - and converts it to a unique string.

Hashing has two important features - it is deterministic and one-way.

Deterministic means that given the same content, the same unique hash will always be generated.

One way means that we can convert from content to hash but not the other way.

---

## Object Store

So Git is just a database.  A project specific flat file databse.

Every project contains a working directory - the files you are editing - and a Git repository - everything in the .git/ directory.  `git init` creates your repo.

There are quite a few file in the repo but the important one for now is `.git/objects`

---

## Objects

Git stores information in `objects` of which there are four types - blobs, trees, commits, and tags.  All objects have a common format however.

Objects are made up of a file name, a header, and content, and are a combination of text and binary data.

The header is simply the object type, followed by a space, the content's size in bytes, and finally a null byte. 

> TYPE - SPACE - SIZE - NULL_BYTE 

The file name is just the SHA1 has of the header and object contents, and when the object is saved, the contents are compressed.

---

## Hashing Objects

To generate the file name, Git passes the header and contents to a SHA1 hash function.  

This can be done manually with `git hash-object` or in our Ruby implementation as:


    require 'digest/sha1'

    module Git
      def self.hash(type, content)
        Digest::SHA1.hexdigest "#{header(type, content)}#{content}"
      end

      def self.header(type, content)
        "#{type.to_s} #{content.bytesize}\x00"
      end
    end


Let's see how this works in comparison to git.


    Git.hash :blob, "I'm doing git in Ruby!\n"
    # => ad666ec7873d557801655cde86cb1911d7931c92

    $ echo "I'm doing git in Ruby!" | git hash-object --stdin
    # => ad666ec7873d557801655cde86cb1911d7931c92


Excellent.  The reason that we add `\n` in the Ruby is that `echo` adds a trailing newline character.

---

## Storing Objects

Git saves objects in the `.git/objects` directory of your repo. 

The directory and file name are derived from the SHA1 hash with the first two characters forming the subdirectory and the remaining 38 becoming the filename.  

So the file that hashes to `ad666ec7873d557801655cde86cb1911d7931c92` will be saved in `.git/objects/ad/666ec7873d557801655cde86cb1911d7931c92`


    module Git
      def self.sha_to_path(sha)
        dir  = ".git/objects/#{sha[0..1]}"
        file = "#{dir}/#{sha[2..-1]}"
        [dir, file]        
      end
    end


To save space, git compresses the file header & contents.  We can implement this in Ruby using [Zlib](http://ruby-doc.org/stdlib-2.2.0/libdoc/zlib/rdoc/Zlib.html) from the standard library.


    require 'zlib'
    require 'fileutils'

    module Git
      def self.save(type, content)
        sha = hash type, content
        dir, file = sha_to_path sha

        unless File.exists? file
          FileUtils.mkdir_p dir
          File.open(file, 'w+') do |f| 
            f.write Zlib::Deflate.deflate(header(type, content) << content)
          end
        end

        sha
      end
    end


We can test this against Git.


    Git.save :blob, "I can't believe it's not Git!\n"
    # => cb1842a3899d41b01feb5543eb3faf3afe65cfb0

    $ git cat-file -p cb1842a
    # => "I can't believe it's not Git!"

---

## Reading Objects

Reading objects is just the reverse of saving them.  

Given a sha1 hash, we determine the path and filename, unzip the content, and then display it based on object type.  

We'll look at how to read type specific content shortly.


    module Git
      def self.read(hash)
        dir, file = sha_to_path hash
        head, *content = Zlib::Inflate.inflate(File.read file).split "\x00"
        type, size = head.split " "
        Git.send "read_#{type}", content.join("\x00")
      end
    end

---

## The Blob

Blobs represent file contents are the most common object type in Git.  

They are simply the compressed object header and file contents so nothing else needs to be implmented.


    module Git
      def self.read_blob(contents)
        contents
      end
    end


Git also looks up a file optimistically but we wont implement that just yet.  This means we'll need to give our Ruby code the full hash.

    Git.read "cb1842a3899d41b01feb5543eb3faf3afe65cfb0" 
    # => "I can't believe it's not Git!\n"

    $ git cat-file -p cb1842
    # => "I can't believe it's not Git!"

---

## The Tree

Blobs are just the SHA1 addressed content so they don't contain any meta data like actual filename or permissions.

This is where Tree objects come in.  Trees are like posix directories in that they contain data about leaves - other trees and blobs.  They look like this.

    # 100644 blob 83ca550b885011f19e7ee36fe840252f9e334f9d    hello.txt
    # 040000 tree 1a80d3bf201288206919102ac3267f6414f8489d    posts

The top level tree begins in the directory whereever the git repo resides.

---

## Tree Format

Git is nothing but consistent about it's inconsistencies so the display representation is unfortunately different from the data structure.  The contents of a tree object look like:

> MODE - SPACE - FILENAME - NULL_BYTE - BINARY_OBJECT_HASH

Because git mixes text and binary data in the tree content, we need a way to go from a 40 character SHA1 to a 20 byte representation of it.

It turns out, we can just treat each 2 char pair as a hex value.


    module Git
      def self.hex_to_bin(hash)
        hash.scan(/../).map { |x| x.hex.chr }.join
      end

      def self.bin_to_hex(hash)
        hash.unpack('H*').first
      end
    end


    Git.hex_to_bin "83ca550b885011f19e7ee36fe840252f9e334f9d"
    # => "\x83\xCAU\v\x88P\x11\xF1\x9E~\xE3o\xE8@%/\x9E3O\x9D"

    Git.bin_to_hex "\x83\xCAU\v\x88P\x11\xF1\x9E~\xE3o\xE8@%/\x9E3O\x9D"
    # => "83ca550b885011f19e7ee36fe840252f9e334f9d"


## Reading Trees

To read a tree, we need to parse its contents.  There is probably a better way but we'll go this with a regex for now and add a method to display the result like Git.


    module Git
      def self.read_tree(contents)
        leaves = []
        contents.gsub /(\d+) (.+?)\x00(.+?)(?=$|100|400)/ do |match|
          leaves.push({mode: $1, name: $2, sha: Git.bin_to_hex($3)})
        end
        leaves
      end

      def self.display_tree(hash)
        Git.read(hash).map do |leaf|
          "%06d" % leaf[:mode] + " #{leaf[:mode].to_i > 100000 ? 'blob' : 'tree'} #{leaf[:sha]} #{leaf[:name]}"
        end
      end
    end

    Git.display_tree "e629cb2a5967c458b98f73ded0d8d38359dcca82"
    $ git cat-file -p e629cb


## Writing Trees

In normal usage, Git will write trees from the index. We won't bother implementing the index here but will instead assume that we are tracking everything in the working directory.  

Instead, we'll pass git a directory from which it should recursively build a tree.  To make life easy, we'll also ignore hidden files & directories.


    module Git
      def self.build_tree(dir=Dir.pwd)
        leaves = []
        Dir.foreach(dir) do |file|
          stat = File::Stat.new("#{dir}/#{file}")
          if stat.directory?
            leaves.push({mode: stat.mode, name: file, sha: Git.save(:tree, Git.build_tree("#{dir}/#{file}"))}) unless File.basename(file)[0] == '.'
          else
            contents = File.read("#{dir}/#{file}") 
            leaves.push({mode: stat.mode, name: file, sha: Git.save(:blob, contents)})
          end
        end
        Git.format_tree leaves
      end

      def self.format_tree(leaves)
        leaves.map {|leaf| "#{sprintf "%o", leaf[:mode]} #{leaf[:name]}\x00#{Git.hex_to_bin leaf[:sha]}" }.join
      end
    end


This is the same as adding everything to the index and writing that.

    Git.save(:tree, Git.build_tree)

    $ git add -A | git write-tree


## The Commit

Commits are objects that point to a root tree and other commits.  This is how histories are created.

Each commit, except for the first commit, points to one or more parent commits forming a directed acyclical graph.

Commits also contain metadata about the author, committer, and time.


    # commit ea8c2f1e26cef2ffd05fe69ecf01fc838ef72c66
    # tree c5d1bcbbd958b1cf13d561552e051ecfc235a11d
    # parent 86483d4f1ef4c00a4a00000d35d01432341d7fa9
    # author Dave Kinkead <dave@kinkead.com.au> 1445860464 +1000
    # committer Dave Kinkead <dave@kinkead.com.au> 1445860464 +1000
    # 
    #     Add implmentation of trees


## Reading Commits

Thankfully, commits are straight up text as per their output!


    module Git
      def self.read_commit(content)
        content
      end
    end

    p Git.read("ea8c2f1e26cef2ffd05fe69ecf01fc838ef72c66")

## Writing Commits


## The Tag


## Branching


## Merging

