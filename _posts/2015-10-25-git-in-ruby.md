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
