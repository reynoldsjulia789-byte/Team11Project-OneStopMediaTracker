/*
CS 340 – Introduction to Databases
Project: NextUp – A One-Stop Media Tracker
Group 11: Julia Reynolds, Stephen Stanwood

File: PL.sql

Contains stored procedures:
- sp_reset_nextup
- sp_demo_delete_user
- sp_insert_user

Original work. No AI used.
CRUD procedures adapted from:
- CS340 Exploration - Implementing CUD operations in your app (https://canvas.oregonstate.edu/courses/2031764/pages/exploration-implementing-cud-operations-in-your-app?module_item_id=26243436)
*/

-- RESET procedure
DROP PROCEDURE IF EXISTS sp_reset_nextup;
DELIMITER //
CREATE PROCEDURE sp_reset_nextup()
BEGIN
  SET FOREIGN_KEY_CHECKS = 0;

  DROP TABLE IF EXISTS UserTrackerEntries;
  DROP TABLE IF EXISTS SportsEvents;
  DROP TABLE IF EXISTS MediaItems;
  DROP TABLE IF EXISTS Users;

  CREATE TABLE Users
  (
      userID      INT NOT NULL AUTO_INCREMENT,
      username    VARCHAR(255) NOT NULL UNIQUE,
      email       VARCHAR(255) NOT NULL UNIQUE,
      PRIMARY KEY (userID)
  );

  CREATE TABLE MediaItems
  (
      mediaItemID INT NOT NULL AUTO_INCREMENT,
      mediaType   ENUM('MOVIE','SHOW','BOOK') NOT NULL,
      title       VARCHAR(255) NOT NULL,
      releaseDate DATETIME,
      runtimeMins INT,
      creator     VARCHAR(255),
      platform    VARCHAR(255),
      PRIMARY KEY (mediaItemID)
  );

  CREATE TABLE SportsEvents
  (
      sportsEventID        INT NOT NULL AUTO_INCREMENT,
      typeOfSport          VARCHAR(255) NOT NULL,
      homeTeam             VARCHAR(255) NOT NULL,
      awayTeam             VARCHAR(255) NOT NULL,
      startTime            DATETIME NOT NULL,
      runtimeMins          INT,
      recordingIsAvailable BOOLEAN,
      platform             VARCHAR(255),
      PRIMARY KEY (sportsEventID)
  );

  CREATE TABLE UserTrackerEntries
  (
      entryID       INT NOT NULL AUTO_INCREMENT,
      userID        INT NOT NULL,
      mediaItemID   INT,
      sportsEventID INT,
      status        ENUM('TO_WATCH','WATCHING','WATCHED'),
      savedAt       DATETIME NOT NULL,
      completedAt   DATETIME,
      PRIMARY KEY (entryID),
      FOREIGN KEY (userID) REFERENCES Users(userID) ON DELETE CASCADE,
      FOREIGN KEY (mediaItemID) REFERENCES MediaItems(mediaItemID) ON DELETE CASCADE,
      FOREIGN KEY (sportsEventID) REFERENCES SportsEvents(sportsEventID) ON DELETE CASCADE,
      CONSTRAINT checkSportsOrMedia CHECK (
        (mediaItemID IS NOT NULL AND sportsEventID IS NULL)
        OR
        (mediaItemID IS NULL AND sportsEventID IS NOT NULL)
      )
  );

  -- initial data
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

  SET FOREIGN_KEY_CHECKS = 1;
END//
DELIMITER ;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- DELETE procedure (hard-coded just for testing)
DROP PROCEDURE IF EXISTS sp_demo_delete_user;
DELIMITER //
CREATE PROCEDURE sp_demo_delete_user()
BEGIN
   DELETE FROM Users WHERE username = 'soph';
END//
DELIMITER ;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

/*
    Users Table Procedures

    In this section:
    - sp_insert_user
    - sp_update_user
    - sp_delete_user
*/

-- Insert/Create New User
drop procedure if exists sp_insert_user;

delimiter //
create procedure sp_insert_user
(
    in  p_username    varchar(255) not null unique,
    in  p_email       varchar(255) not null unique,
    out p_userID      int
)
begin
    -- Insert data into users table
    insert into Users (username,   email)
    values            (p_username, p_email);

    -- Store the ID of the last inserted row
    select last_insert_id() into p_userID;

    -- Display the ID of the last inserted person.
    select last_insert_id() AS 'newID';

    -- Example of how to get the ID of the newly created person:
        -- CALL sp_CreatePerson('Theresa', 'Evans', 2, 48, @new_id);
        -- SELECT @new_id AS 'New Person ID';
end //
delimiter ;

-- Update User
drop procedure if exists sp_update_user

delimiter //
create procedure sp_update_user
(
    in p_userID     int not null,
    in p_username   varchar(255) not null unique,
    in p_email      varchar(255) not null unique,
)
begin
    update  Users
    set     username = p_username,
            email    = p_email
    where   userID   = p_userID;
end //
delimiter ;

-- Delete User
drop procedure if exists sp_delete_user

delimiter //
create procedure sp_delete_user
(
    in p_userID     int not null
)
begin
    declare error_message varchar(255);

    -- error handling
    declare exit handler for sqlexception
    begin
        -- roll back the transaction on any error
        rollback;
        -- propogate the custom error message to the caller
        resignal;
    end;

    start transaction;
        -- delete the corresponding row from Users
        delete from Users
        where       userID = p_userID;

        -- number of rows affected by the preceding statement.
        if row_count() = 0 then
            set error_message = concat('No matching record found in Users for userID: ', p_userID);
            -- Trigger custom error, invoke exit handler
            signal sqlstate '45000' set message_text = error_message;
        end if;

    commit;
end //
delimiter ;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

/*
    Sports Events Table Procedures

    In this section:
    - sp_insert_sports_event
    - sp_update_sports_event
    - sp_delete_sports_event
*/

-- Insert/Create New Sports Event
drop procedure if exists sp_insert_sports_event;

delimiter //
create procedure sp_insert_sports_event
(
    in  p_typeOfSport          VARCHAR(255) NOT NULL,
    in  p_homeTeam             VARCHAR(255) NOT NULL,
    in  p_awayTeam             VARCHAR(255) NOT NULL,
    in  p_startTime            DATETIME NOT NULL,
    in  p_runtimeMins          INT,
    in  p_recordingIsAvailable BOOLEAN,
    in  p_platform             VARCHAR(255),
    out p_sportsEventID        int
)
begin
    -- Insert data into sports events table
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
        p_typeOfSport,
        p_homeTeam,
        p_awayTeam,
        p_startTime,
        p_runtimeMins,
        p_recordingIsAvailable,
        p_platform
    );

    -- Store the ID of the last inserted row
    select last_insert_id() into p_sportsEventID;

    -- Display the ID of the last inserted person.
    select last_insert_id() AS 'newID';
end //
delimiter ;

-- Update Sports Events
drop procedure if exists sp_update_sports_events

delimiter //
create procedure sp_update_sports_events
(
    in  p_sportsEventID        int not null,
    in  p_typeOfSport          VARCHAR(255) NOT NULL,
    in  p_homeTeam             VARCHAR(255) NOT NULL,
    in  p_awayTeam             VARCHAR(255) NOT NULL,
    in  p_startTime            DATETIME NOT NULL,
    in  p_runtimeMins          INT,
    in  p_recordingIsAvailable BOOLEAN,
    in  p_platform             VARCHAR(255)
)
begin
    update  SportsEvents
    set     typeOfSport          = p_typeOfSport,
            homeTeam             = p_homeTeam,
            awayTeam             = p_awayTeam,
            startTime            = p_startTime,
            runtimeMins          = p_runtimeMins,
            recordingIsAvailable = p_recordingIsAvailable,
            platform             = p_platform
    where   sportsEventID        = p_sportsEventID;
end //
delimiter ;

-- Delete Sports Event
drop procedure if exists sp_delete_sports_event

delimiter //
create procedure sp_delete_sports_event
(
    in p_sportsEventID     int not null
)
begin
    declare error_message varchar(255);
    
    -- error handling
    declare exit handler for sqlexception
    begin
        -- roll back the transaction on any error
        rollback;
        -- propogate the custom error message to the caller
        resignal;
    end;

    start transaction;
        -- delete the corresponding row from SportsEvents
        delete from SportsEvents
        where       sportsEventID = p_sportsEventID;

        -- number of rows affected by the preceding statement.
        if row_count() = 0 then
            set error_message = concat('No matching record found in Users for userID: ', p_userID);
            -- Trigger custom error, invoke exit handler
            signal sqlstate '45000' set message_text = error_message;
        end if;

    commit;
end //
delimiter ;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

/*
    Media Items Table Procedures

    In this section:
    - sp_insert_media_item
    - sp_update_media_item
    - sp_delete_media_item
*/

-- Insert/Create New Media Item
drop procedure if exists sp_insert_media_item;

delimiter //
create procedure sp_insert_media_item
(
    in  p_mediaType           ENUM('MOVIE','SHOW','BOOK') NOT NULL,
    in  p_title               VARCHAR(255) NOT NULL,
    in  p_releaseDate         DATETIME,
    in  p_runtimeMins         INT,
    in  p_creator             VARCHAR(255),
    in  p_platform            VARCHAR(255),
    out p_mediaItemID         int
)
begin
    -- Insert data into Media Items table
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
        mediaType   = p_mediaType,  
        title       = p_title,      
        releaseDate = p_releaseDate,
        runtimeMins = p_runtimeMins,
        creator     = p_creator,    
        platform    = p_platform
    );

    -- Store the ID of the last inserted row
    select last_insert_id() into p_mediaItemID;

    -- Display the ID of the last inserted person.
    select last_insert_id() AS 'newID';
end //
delimiter ;

-- Update User
drop procedure if exists sp_update_media_item

delimiter //
create procedure sp_update_media_item
(
    in  p_mediaItemID     int not null,
    in  p_mediaType       ENUM('MOVIE','SHOW','BOOK') NOT NULL,
    in  p_title           VARCHAR(255) NOT NULL,
    in  p_releaseDate     DATETIME,
    in  p_runtimeMins     INT,
    in  p_creator         VARCHAR(255),
    in  p_platform        VARCHAR(255),
)
begin
    update  MediaItems
    set     mediaType   = p_mediaType,  
            title       = p_title,      
            releaseDate = p_releaseDate,
            runtimeMins = p_runtimeMins,
            creator     = p_creator,    
            platform    = p_platform
    where   mediaItemID = p_mediaItemID;
end //
delimiter ;

-- Delete User
drop procedure if exists sp_delete_media_item

delimiter //
create procedure sp_delete_media_item
(
    in p_mediaItemID      int not null
)
begin
    declare error_message varchar(255);

    -- error handling
    declare exit handler for sqlexception
    begin
        -- roll back the transaction on any error
        rollback;
        -- propogate the custom error message to the caller
        resignal;
    end;

    start transaction;
        -- delete the corresponding row from Media Items
        delete from MediaItems
        where       mediaItemID = p_mediaItemID;

        -- number of rows affected by the preceding statement.
        if row_count() = 0 then
            set error_message = concat('No matching record found in Users for userID: ', p_userID);
            -- Trigger custom error, invoke exit handler
            signal sqlstate '45000' set message_text = error_message;
        end if;

    commit;
end //
delimiter ;

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

/*
    User Tracker Entries Table Procedures

    In this section:
    - sp_insert_tracker_entry
    - sp_update_tracker_entry
    - sp_delete_tracker_entry
*/