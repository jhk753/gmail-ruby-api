# Gmail for Ruby

A Ruby interface to Gmail API: Search, 
read and send multipart emails, archive, mark as read/unread, delete emails, 
and manage labels. Everything goes through Gmail API (and not through IMAP or SMTP protocols)

[![Gem Version](https://badge.fury.io/rb/gmail-api-ruby.svg)](http://badge.fury.io/rb/gmail-api-ruby)
[![Build Status](https://travis-ci.org/jhk753/gmail-ruby-api.svg)](https://travis-ci.org/jhk753/gmail-ruby-api)
[![Dependency Status](https://gemnasium.com/jhk753/gmail-ruby-api.svg)](https://gemnasium.com/jhk753/gmail-ruby-api)


# Notice

If for your usecase, the gem is too limited there are two solutions for you:

1. Contribute ;)
2. Look at [Gmail Api doc](https://developers.google.com/gmail/api/v1/reference) to:
    * Do custom query by adding parameters I didn't talk about in my doc
    * If for some reason I forgot to build some methods, note that you can call fully custom request via Gmail.client (Standard Google Api Client)

# To Do

* write proper error handling

## Installation

    gem install gmail-api-ruby

## Initialization

```ruby
    Gmail.client_id = "...Your app client id..."
    Gmail.client_secret = "...Your app Secret..."
    Gmail.refresh_token = "...the refresh token of the Gmail account you want to use..."
```

## Usage

```ruby
    require "Gmail"
```

### Common methods

this works for Messages, Labels, Drafts and Threads (everything)

```ruby
   Gmail::Message.all
   Gmail::Message.all(maxResults: -1) #will parse everything. Use with care. Can through request timeout if used in web apps
   Gmail::Message.get(message_id)
   some_gmail_message.delete
```

this will work for Messages and Threads

```ruby
   some_message.archive
   some_message.un_archive
   some_message.trash
   some_message.un_trash
   some_message.star
   some_message.un_star
   some_message.mark_as_read
   some_message.mark_as_unread
   
   Gmail::Message.search(in: "labelId" from: "me@gmail.com", to: "you@gmail.com, theothers@gmail.com", subject: "some subject", after: "date", before: "date", has_words: "some words", has_not_words: "some text")
   Gmail::Message.search("some words") #search as you would do in gmail interface
 
 ```


### Message

Create a Message object

```ruby
    m = Gmail::Message.new(
        from: "test@test.com",
        to: "hello@world.com",
        subject: "this is the subject",
        body: "this is a text body")
```

If you want a multipart message

```ruby
    m = Gmail::Message.new(
        from: "test@test.com",
        to: "hello@world.com",
        subject: "this is the subject",
        text: "this is a text body",
        html: "<div>this is a html body</div>",
        labelIds: ["cool label", "Newsletter"] #labelIds is always array of labels
        )
```

From this you can create a Draft in Gmail

```ruby
    m.create_draft
```

or just send the Message

```ruby
    m.deliver
```

Notice that the Message object can use from, to, cc, bcc, threadId, labelIds, text, html, body

If you need to send Message or create draft with custom headers or set other headers.
Or if you need to create a different multipart email, you need to build the "raw" email yourself

example:

```ruby
    mail = Mail.new #this is the native ruby Mail object
    #
    # construct your Mail object
    #
    raw = Base64.urlsafe_encode64 mail.to_s
    m = Gmail::Message.new(raw: raw)
```

In that scenario, you still assign, if needed, ThreadId and labelIds as previously

```ruby
    m.threadId = "somethreadId"
    m.labelIds = ["cool label"]
```

If you want to quickly generate a reply or a forward to message

```ruby
    # this will construct everything for you, keeping the subject the thread etc as it would happen in Gmail
      # reply only to the sender of Message m.
        msg = m.reply_sender_with Gmail::Message.new(body: "some reply text")
      # reply to all (sender, to (without yourself) and cc)
        msg = m.reply_all_with Gmail::Message.new(body: "some reply text")
      # forward
        msg = m.forward_with Gmail::Message.new(body: "some forward text", to: "address@toforward.com")
    # Note that the above will not send the resulting msg
        msg.deliver #to send the constructed reply message
        
```

Other stuffs that you can do with Message object

```ruby
    m.detailed #if for any reason Google did send us the full detail of on email object
    m.thread #to get the associated Thread
    m.inbox? #to know if email is in inbox
    m.sent? #to know if email is a sent email
    m.unread? #to know if email is unread
```

Those are basics helpers feel free to add more if you want (ex: starred?, important?, etc)


## Thread

Get a thread

```ruby
   one_thread = Gmail::Thread.get(thread_id)
```

or

```ruby
   one_thread = one_message.thread
```

Filter messages in Thread

```ruby
   one_thread.unread_messages
   one_thread.sent_messages
```

Expand messages in Thread

```ruby
   one_thread.detailed #this will return a thread object but with all messages detailed
   one_thread.messages #this will return an array of message objects
```

## Draft

As we explained in Message, you create a draft with

```ruby
    d = some_message.create_draft
```

Modify it with

```ruby
    d.message.subject = "some different subject than before"
    d.save
```

send it with

```ruby
    d.deliver
```

## Label

You can create a label like this:

```ruby
    l = Gmail::Label.new
    l.name = "different Name"
    l.messageListVisibility = "hide" #can be 'hide' or 'show'
    l.labelListVisibility = "labelShowIfUnread" #can be "labelShowIfUnread", "labelShow", "labelHide"
    l.save
```

You can modify a label like this:

```ruby
    l = Gmail::Label.get("labelId")
    l.name = "different Name"
    l.messageListVisibility = "hide"
    l.labelListVisibility = "labelShowIfUnread"
    l.save
```

You can use Labels to directly access box information

```ruby
    l.detailed #will display number of messages and number of threads if you don't see it
```

For system labels like inbox, sent, trash, important, starred, draft, spam, unread, category_updates, category_promotions, category_social, category_personal, category_forums

```ruby
    l = Gmail::Label.inbox
```

Access threads and messages from labels

```ruby
    l.threads
    l.messages

    l.unread_threads
    l.unread_messages
```

Access threads, drafts and messages with labels

```ruby
    Gmail::Message.all(labelIds: ["UNREAD", "INBOX"])
```

## License

Copyrignt (c) 2015 Julien Hobeika

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.