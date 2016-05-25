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


    module Git
      class Obj
        def initialize(content=nil)
          parse content
        end

        def parse(content)
          @type = :blob
          @content = content || ''
        end

        def header
          "#{@type.to_s} #{@content.bytesize}\x00"
        end
      end

      class Blob < Obj; end
      class Tree < Obj; end
      class Commit < Obj; end
      class Tag < Obj; end      
    end


The file name is just the SHA1 has of the header and object contents, and when the object is saved, the contents are compressed.

---

## Hashing Objects

To generate the file name, Git passes the header and contents to a SHA1 hash function.  

This can be done manually with `git hash-object` or in our Ruby implementation as:


    require 'digest/sha1'

    module Git
      class Obj
        def hash
          Digest::SHA1.hexdigest header + @content
        end
      end
    end


Let's create a top level API and see how this works in comparison to Git itself.


    module Git
      def self.hash(content)
        Git::Obj.new("I'm doing git in Ruby!\n").hash
      end
    end

    Git.hash "I'm doing git in Ruby!\n"
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
      class Obj
        def save
          dir, file = Git.sha_to_path hash

          unless File.exists? file
            FileUtils.mkdir_p dir
            File.open(file, 'w+') do |f| 
              f.write Zlib::Deflate.deflate(header << @content)
            end
          end

          hash
        end
      end
    end


Testing this against Git, we can see how it performs.

    Git::Obj.new("I can't believe it's not Git!\n").save
    # => cb1842a3899d41b01feb5543eb3faf3afe65cfb0

    $ git cat-file -p cb1842a
    # => "I can't believe it's not Git!"


## Reading Objects

Reading objects is just the reverse of saving them.  

Given a sha1 hash, we find it determine the path and filename, unzip the content, and then display it based on object type.  


    module Git
      class Obj
        def self.find(sha)
          dir, file = Git.sha_to_path sha
          head, *content = Zlib::Inflate.inflate(File.read file).split "\x00"
          type, size = head.split " "
          Git.const_get("#{type.capitalize}").new content.join("\x00")
        end

        def show
          @content
        end
      end
    end


We will also add the method `show` to our API


    module Git
      def self.show(sha)
        Git::Obj.find(sha).show
      end
    end

    Git.show "cb1842a3899d41b01feb5543eb3faf3afe65cfb0" 
    # => "I can't believe it's not Git!\n"

    $ git cat-file -p cb1842a3899d41b01feb5543eb3faf3afe65cfb0
    # => "I can't believe it's not Git!"

---

## The Blob

Blobs represent file contents are the most common object type in Git.  

They are simply the compressed object header and file contents.  This is the same as the default so nothing else needs to be implmented.


    module Git
      class Blob < Obj
      end
    end

    Git::Blob.new("Why am I so ugly :(\n").save
    # => "b7537519a566c40d554f7b599ec4ff2b418c1df3"

---

## The Tree

Blobs are just the SHA1 addressed content so they don't contain any meta data like actual filename or permissions.

This is where Tree objects come in.  Trees are like posix directories in that they contain data about leaves - other trees and blobs.  They look like this:


    # 100644 blob 83ca550b885011f19e7ee36fe840252f9e334f9d    hello.txt
    # 040000 tree 1a80d3bf201288206919102ac3267f6414f8489d    posts


The top level tree begins in the directory whereever the git repo resides.

---

## Tree Format

Git is nothing but consistent about it's inconsistencies so the display representation of a tree is different from the data structure.  What's more, the contents of a tree include both ACSII and binary data.


    # MODE - SPACE - FILENAME - NULL_BYTE - BINARY_OBJECT_HASH


This means we will need a helper to convert from a 40 character SHA1 to a 20 byte representation of it, and back again.  Luckily, this is nothing more than treating each 2 char ASCII pair as a single hex value.


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

---


## Reading Trees

To read a tree, we need to parse its contents.  There is probably a better way but we'll go this with a regex for now and add a method to display the result like Git.


    module Git
      class Tree
        def parse(content)
          super
          @type = :tree
          @leaves = []
          @content.gsub /(\d+) (.+?)\x00(.+?)(?=$|100|400)/ do |match|
            @leaves.push({mode: $1, name: $2, sha: Git.bin_to_hex($3)})
          end unless @content.nil?
        end

        def show
          @leaves.map do |leaf|
            "%06d" % leaf[:mode] + " #{leaf[:mode].to_i > 100000 ? 'blob' : 'tree'} #{leaf[:sha]} #{leaf[:name]}"
          end
        end
      end
    end


    Git.show "e629cb2a5967c458b98f73ded0d8d38359dcca82"
    $ git cat-file -p e629cb

---

## Writing Trees

In normal usage, Git will write trees from the index. We won't bother implementing the index here but will instead assume that we are tracking everything in the working directory.  
Instead, we'll pass git a directory from which it should recursively build a tree.  To make life easy, we'll also ignore hidden files & directories.


    module Git
      class Tree
        attr_accessor :leaves

        def self.write(dir=Dir.pwd)
          tree = Git::Tree.new

          Dir.foreach(dir) do |file|
            stat = File::Stat.new("#{dir}/#{file}")
            if stat.directory?
              tree.leaves.push({mode: "#{sprintf "%o", stat.mode}", name: file, sha: Git::Tree.write("#{dir}/#{file}").hash}) unless File.basename(file)[0] == '.'
            else
              contents = File.read("#{dir}/#{file}") 
              tree.leaves.push({mode: "#{sprintf "%o", stat.mode}", name: file, sha: Git::Blob.new(contents).hash})
            end
          end

          tree
        end
      end
    end


This is the same as adding everything to the index and writing that.

    Git::Tree.write.show

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

Thankfully, commits are straight up text as per their output!  All we need to do is grab the tree and parent data.


    module Git
      class Commit
        def parse(content)
          super
          @type = :commit
          @parents = []

          @content.gsub /(.+?) (.+?)\n/ do |match|
            @tree = $2 if $1 == 'tree'
            @parents.push $2 if $1 == 'parent'
          end
          
          @content.gsub /\n\n(.+)$/ do |match|
            @message = $1
          end
        end
      end
    end

    Git.show "ea8c2f1e26cef2ffd05fe69ecf01fc838ef72c66"

---

## References

A big part of the Git ontology is the Object - blobs, trees, commits, & tags.  Another key bit are references which we now need to address before continuing.

References are just textfile symlinks to commits or other references.

The `HEAD` file is simply a reference to the current branch like `ref: refs/heads/master`.

The `ORIG_HEAD` file is simply a reference to the last commit `ea8c2f1e26cef2ffd05fe69ecf01fc838ef72c66`.

---

## Branches

Branches are also references.  Many people seem to think that branches are forks or code but they are nothing more than a symlink to a commit.

That's it. They are just text files with a single SHA1 hash of a commit object.

    
    module Git
      def self.branch(name)
        File.read(".git/refs/heads/#{name}").strip
      end

      def self.HEAD
        current_branch = File.read(".git/HEAD")
        current_branch.split('/').last.strip
      end
    end

    Git.branch "master"
    Git.HEAD

---

## Branching

Create a branch by setting the current commit to `.git/refs/heads/branchname`, and updating the HEAD to that branch.


    module Git
      def self.branch!(name)
        last_commit = Git.branch(Git.HEAD)
        File.open ".git/refs/heads/#{name}", "w+" do |file|
          file.write last_commit
        end
        last_commit
      end
    end

    #Git.branch! "git-in-ruby-demo"


Update the HEAD
Checkout a commit from branch

---

## Writing Commits

Writing commits is just the opposite of reading them.

  
    module Git
      class Commit
        def self.write(info)
          content = "tree #{info[:tree]}\n"
          info[:parents].each { |parent| @content << "parent #{parent}\n" }
          content << "committer Biggus Diggus <biggus@diggus.rm> time\n\n"
          content << info[:message]
        end
      end
    end

    



## Committing

Commiting is like taking a snapshot - typically from the index.

We haven't talked much about the index yet but it is very similar to a tree for the root directory.  You add files to the index with `git add filename` and can view it with `git ls-files -s`

For simplicity, we will assume the index is the same as the root directory and commit that.

Commiting then, involves writing a tree from the index, creating a commit object, and updating the refs.

Update ORIG_HEAD to last commit


## Checkout

Update the HEAD to `ref: refs/heads/gh-pages`
Update the working DIR


## Merging

Git.read
Obj.
Obj.write
Git.write :type, content
Git.add
Git.hash
Git.commit
Git.log