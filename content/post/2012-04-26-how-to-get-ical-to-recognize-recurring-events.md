+++
date = "2012-04-26"
title = "How to get iCal to recognize recurring events in iCalendar (ics) files"
slug = "how-to-get-ical-to-recognize-recurring-events"
aliases = [
    "/post/21850303360/how-to-get-ical-to-recognize-recurring-events-in"
]
+++

Here is the solution to a problem I recently debugged which I had a very hard
time finding any information on via Google. Hopefully this helps someone else
in the future.

When programatically generating [iCalendar][] (.ics) files, iCal on OS X (at
least on my Snow Leopard version, 4.0.4) seems to refuse to recognize that the
event is recurring if the `VEVENT` contains a `RECURRENCE-ID` element.

For an event that should repeat on the first Thursday of the month, iCal would
only add the first event if the ICS file looked like this:

```
BEGIN:VEVENT
DTSTAMP:20120425T210028Z
DTSTART;TZID=America/New_York:20120503T180000
DTEND;TZID=America/New_York:20120503T190000
SUMMARY:This event should repeat on first Thursday of the month
RRULE:FREQ=MONTHLY;INTERVAL=1;COUNT=4;BYDAY=1TH
RECURRENCE-ID;TZID=America/New_York:20120503T180000
```

However, remove the `RECURRENCE-ID` element and iCal recognizes that this is a
recurring event just fine - it adds events on the first Thursday of the month
for four months:

```
BEGIN:VEVENT
DTSTAMP:20120425T210028Z
DTSTART;TZID=America/New_York:20120503T180000
DTEND;TZID=America/New_York:20120503T190000
SUMMARY:This event should repeat on first Thursday of the month
RRULE:FREQ=MONTHLY;INTERVAL=1;COUNT=4;BYDAY=1TH
```

Outlook 2011 and Google Calendar recognize the first example as hoped for
(shows an event that repeats on first Thursday of the month four times). It’s
not clear to me from [the RFC][] which behavior is correct - the meaning of
`RECURRENCE-ID` seems confusing.


[iCalendar]: http://en.wikipedia.org/wiki/Icalendar
[the RFC]: http://tools.ietf.org/html/rfc5545#section-3.8.7.4
