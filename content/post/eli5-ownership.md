+++
date = 2019-07-14T17:38:48+01:00
description = "Simple introduction to Rust's ownership system"
title = "Here be (owned) books"

[taxonomies]
tags = [
  "rust",
  "programming",
  "ownership",
  "eli5",
  "borrowing"
]
+++

One of Rust's biggest pros is its unique ownership system. Unfortunately, it is
also one of the hardest things to learn. In this article I will try to explain
it the same way I had learned it and how I introduce it to people.

**Disclaimer**: If you do not find this article helpful try to search for another.
People are different and different things *zing* them.

## Let's have a book

Ownership becomes simple and natural if you just acknowledge it as an
application of real world relationships. For example, imagine types in Rust as
a kind of written note. We have different types of notes and based on that, each
of them will be handled differently.

- short ones, like phone no. of the hot waiter/waitress
- longer ones, like this article
- longest ones, like a *Lord of the Rings*

Using this analogy let me try to introduce you, dear reader, to the amazing
world of Rust's ownership.

## One can own the book

Each note, no matter what size it is, can have one owner. Me, you, anyone, it
doesn't matter, but there will be only one owner. You can do whatever you want
with such note but with that power comes, not so great, responsibility: after
you are done with this book you will need to get rid of it. Since you are a law
abiding citizen you will recycle the note in the appropriate receptacle, but it is your
responsibility to do it. Of course this is not the only way to deal with a note. You
can also give it to someone and then it will be hers or his responsibility.

To rephrase it in the Rust way, it would look like this:

```rust
struct Note;

fn john() {
    let book = Note; // john creates the book and he owns it

    // here he can do whatever he want with our `book`
} // at the end of his life john will destroy all his belongings

fn steve() {
    let book = Note; // new book

    // he can do whatever he wants to do with his book

    sally(book);
    // steve gives the book to `sally`,
    // Sally has the responsibility to destroy it

    // now steve cannot do anything with this book,
    // as it is not his personal belonging anymore
}
```

## One can borrow the book

When we don't want to give someone a book (we like that one), we can also lend
them one. And there are two ways to borrow one book:

- We can edit that book (ex. it is our personal dairy) and we lend it to someone
  to check our spelling. We trust that person and we explicitly allow her to
  edit our notes in place. We call it **mutable borrow**.
- We do not trust someone and we lend our beloved book with no permission to edit
  it. Even more, that person knows, that writing something in that book will
  make us go rampage and destroy the whole universe. It will be an **immutable
  borrow**.

Of course if we borrow something from someone else, then we can lend it further
with the same rules that were applied to us.

Rust also ensures that **mutable borrow** is unique. There will never be more
than one person that will be allowed to edit the book. We can still create a chain
of trust - like when I find someone who is better at English than me, I would
allow this person to correct an article written by me or my friend who has
entrusted me with correcting his text.

**Immutable borrows** aren't exclusive. I can lend my books as many times as I
want with one exception: I cannot lend a book that is still borrowed by someone
who can change its content.

In Rust it would look like that:

```rust
fn my() {
    let mut book = Note;

    spelling_corrector(&mut book);
    // we must explicitly mention that we lend the book
    // and we don't give it away

    reader(&book);
}

fn spelling_corrector(book: &mut Note) {
    // correct spelling in place
}

fn reader(book: &Note) {
    // read a book
}
```

## Not all notes are worth borrowing

Sometimes this whole process of lending and then receiving a note back is much
more complicated then just cloning the whole note for someone else. Imagine that
you are in school and friend wants to copy your homework. What you do is lend
your homework to him, and with caution he can clone it on his own. This is what
Rust's `Clone` trait provides - a method to clone content of struct without moving
its ownership.

```rust
#[derive(Clone)]
struct Homework;

fn my() {
    let homework = Homework;

    friend(&homework);
}

fn friend(work: &Homework) { // we lend it immutably
    let mut homework: Homework = work.clone();
    // your friend now has his own modifiable copy
}
```

But some notes are even shorter than that. They are so short and easy to clone
that it is much easier to clone them every time, instead of explicitly
calling the method. Like when you give your phone number to a hot girl at the 
bar, the `Copy` trait automatically clones your note so the other has their own copy. 
Again, this is for small types that can be mechanically copied each time when needed.

```rust
#[derive(Copy, Clone)]
// everything that is `Copy` must be also `Clone`
struct PhoneNo;

fn my() {
    let no = PhoneNo;

    hot_stuff(no);
}

fn hot_stuff(no: PhoneNo) {
    // fingers crossed
}
```

## Conclusion

There is more to learn, but these are the basic laws of ownership in Rust.
Everything else is based on this. If you understand this, it will become much
easier for you to understand how other types behave and, more importantly, why
they work the way they do.
