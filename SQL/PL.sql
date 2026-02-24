/*
CS 340 – Introduction to Databases
Project: NextUp – A One-Stop Media Tracker
Group 11: Julia Reynolds, Stephen Stanwood

File: PL.sql

Contains stored procedures:
- sp_reset_nextup
- sp_demo_delete_user

Original work. No AI or external resources were used.
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

-- DELETE procedure (hard-coded just for testing)
DROP PROCEDURE IF EXISTS sp_demo_delete_user;
DELIMITER //
CREATE PROCEDURE sp_demo_delete_user()
BEGIN
   DELETE FROM Users WHERE username = 'soph';
END//
DELIMITER ;