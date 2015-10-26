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

