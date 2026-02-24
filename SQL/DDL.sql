/*
CS 340 – Introduction to Databases
Project: NextUp – A One-Stop Media Tracker
Group 11: Julia Reynolds, Stephen Stanwood

File: CreateTables.sql
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

-- Insert sample users
insert into Users (username, email)
values
('stephen', 'stephen@example.com'),
('julia',   'julia@example.com'),
('soph',    'soph@example.com');

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

-- End of recommended wrapper
set FOREIGN_KEY_CHECKS = 1;
commit;
set AUTOCOMMIT = 1;