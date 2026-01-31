/*
CS 340 – Introduction to Databases
Project Step 2 Draft – Normalized Schema + DDL with Sample Data
Project: NextUp – A One-Stop Media Tracker
Group 11: Julia Reynolds, Stephen Stanwood

File: InsertSampleData.sql
Purpose: Inserts sample data to fit the NextUp database schema.

Original work. No AI or external resources were used.
*/

insert into Users (username, email)
values            
    ('julia', 'julia@nextup.dev'),
    ('stephen', 'stephen@nextup.dev'),
    ('soph', 'soph@nextup.dev');

insert into MediaItems
    (
        mediaType,
        title, 
        releaseDate, 
        runtimeMins, 
        creator, 
        platform
    )
values
    (
        'MOVIE',
        'Big Fish',
        '2003-12-10 00:00:00',
        125,
        'Tim Burton',
        'Prime Video'
    ),
    (
        'SHOW',
        'The Americans',
        '2013-01-30 00:00:00',
        45,
        'Joe Weisberg',
        'FX'
    ),
    (
        'BOOK',
        'The World According to Garp',
        '1978-03-01 00:00:00',
        null,
        'John Irving',
        null
    );

insert into SportsEvents
    (
        typeOfSport,
        homeTeam,
        awayTeam,
        startTime,
        runtimeMins,
        recordingIsAvailable,
        platform
    )
values
    (
        'Football',
        'Pittsburgh Steelers',
        'Arizona Cardinals',
        '2009-02-01 18:31:00',
        218,
        true,
        'NBC'
    ),
    (
        'Basketball',
        'Golden State Warriors',
        'Boston Celtics',
        '2022-06-16 21:00:00',
        140,
        true,
        'ABC'
    ),
    (
        'Baseball',
        'Chicago Cubs',
        'Cleveland Guardians',
        '2016-11-02 20:02:00',
        268,
        true,
        'FOX'
    );

insert into UserTrackerEntries
    (
        userID,
        mediaItemID,
        sportsEventID,
        status,
        savedAt,
        completedAt
    )
values
    -- Julia & The Americans
    (
        1,
        2,
        null,
        'WATCHING',
        '2026-01-10 08:00:00',
        null
    ),

    -- Soph & Warriors/Celtics (2022 NBA Finals)
    (
        3,
        null,
        2,
        'TO_WATCH',
        '2026-01-12 18:30:00',
        null
    ),

    -- Stephen & Big Fish
    (
        2,
        1,
        null,
        'WATCHED',
        '2026-01-05 20:00:00',
        '2026-01-06 21:45:00'
    ),
    
    -- Stephen & Steelers vs Cardinals (Super Bowl)
    (
        2,
        null,
        1,
        'WATCHED',
        '2026-01-12 09:00:00',
        '2026-01-12 12:45:00'
    ),
    
    -- Soph & The World According to Garp
    (
        3,
        3,
        null,
        'TO_WATCH',
        '2026-01-15 10:30:00',
        null
    );