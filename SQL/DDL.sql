/*
CS 340 – Introduction to Databases
Project: NextUp – A One-Stop Media Tracker
Group 11: Julia Reynolds, Stephen Stanwood

File: DDL.sql
Purpose: Defines the normalized database schema (DDL) for the NextUp project.

Original work. No AI used.
Referred to MySQL documentation on check constraints at the recommendation of peers.
*/

-- Wrapper recommended in the instructions
set FOREIGN_KEY_CHECKS = 0;
set AUTOCOMMIT = 0; 

drop table if exists UserTrackerEntries;
drop table if exists SportsEvents;
drop table if exists MediaItems;
drop table if exists Users;

-- Stores information about the app's users
create table Users
(
    userID      int not null auto_increment,
    primary key (userID),
    username    varchar(255) not null unique,
    email       varchar(255) not null unique
);

-- Stores information about movies, TV shows, and books
create table MediaItems
(
    mediaItemID int not null auto_increment,
    primary key (mediaItemID),
    mediaType   enum('MOVIE','SHOW','BOOK') not null,
    title       varchar(255) not null,
    releaseDate datetime,
    runtimeMins int,
    creator     varchar(255),
    platform    varchar(255)
);

-- Stores information about scheduled sports events
create table SportsEvents
(
    sportsEventID           int not null auto_increment,
    primary key             (sportsEventID),
    typeOfSport             varchar(255)  not null,
    homeTeam                varchar(255)  not null,
    awayTeam                varchar(255)  not null,
    startTime               datetime not null,
    runtimeMins             int,
    recordingIsAvailable    boolean,
    platform                varchar(255)
);

-- Stores information about a particular user’s tracking relationship with a specific media or sports event
create table UserTrackerEntries
(
    entryID         int not null auto_increment,
    primary key     (entryID),
    userID          int not null,
    foreign key     (userID)        references Users(userID) on delete cascade,

    -- Connect Sports/Media to track for the user
    mediaItemID     int,
    foreign key     (mediaItemID)   references MediaItems(mediaItemID) on delete cascade,
    sportsEventID   int,
    foreign key     (sportsEventID) references SportsEvents(sportsEventID) on delete cascade,

    -- Check that either Sports or Media is tracked but not both
    constraint      checkSportsOrMedia
                    check
                    (
                        (mediaItemID is not null and sportsEventID is null) or
                        (mediaItemID is null and sportsEventID is not null)
                    ),

    status          enum('TO_WATCH','WATCHING','WATCHED'),
    savedAt         datetime not null,
    completedAt     datetime
);

-- Insert default sample data for testing
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
    
-- End of recommended wrapper
set FOREIGN_KEY_CHECKS = 1;
commit;
set AUTOCOMMIT = 1;