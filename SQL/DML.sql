/*
CS 340 – Introduction to Databases
Project: NextUp – A One-Stop Media Tracker
Group 11: Julia Reynolds, Stephen Stanwood

File: DML.sql

Original work. No AI or external resources were used.
*/

--- SELECT ---

-- Browse all Users
select userID, username, email
from Users;

-- Browse all MediaItems
select mediaItemID, mediaType, title, releaseDate, runtimeMins, creator, platform
from MediaItems;

-- Browse all SportsEvents
select sportsEventID, typeOfSport, homeTeam, awayTeam, startTime, runtimeMins, recordingIsAvailable, platform
from SportsEvents;

-- Browse all UserTrackerEntries
select entryID, userID, mediaItemID, sportsEventID, status, savedAt, completedAt
from UserTrackerEntries;

--- INSERT ---

-- Add a new User
insert into Users (username, email)
values (@usernameInput, @emailInput);

-- Add a new MediaItem
insert into MediaItems
    (mediaType, title, releaseDate, runtimeMins, creator, platform)
values
    (@mediaTypeInput, @titleInput, @releaseDateInput, @runtimeMinsInput, @creatorInput, @platformInput);

-- Add a new SportsEvent
insert into SportsEvents
    (typeOfSport, homeTeam, awayTeam, startTime, runtimeMins, recordingIsAvailable, platform)
values
    (@typeOfSportInput, @homeTeamInput, @awayTeamInput, @startTimeInput, @runtimeMinsInput, @recordingIsAvailableInput, @platformInput);

-- Add a new UserTrackerEntry (Media item)
insert into UserTrackerEntries
    (userID, mediaItemID, sportsEventID, status, savedAt, completedAt)
values
    (@userIDInput, @mediaItemIDInput, null, @statusInput, @savedAtInput, @completedAtInput);

-- Add a new UserTrackerEntry (Sports event)
insert into UserTrackerEntries
    (userID, mediaItemID, sportsEventID, status, savedAt, completedAt)
values
    (@userIDInput, null, @sportsEventIDInput, @statusInput, @savedAtInput, @completedAtInput);

--- UPDATE ---

-- Update a User
update Users
set 
    username = @usernameInput, 
    email = @emailInput
where userID = @userIDInput;

-- Update a MediaItem
update MediaItems
set 
    mediaType = @mediaTypeInput, 
    title = @titleInput,
    releaseDate = @releaseDateInput,
    runtimeMins = @runtimeMinsInput,
    creator = @creatorInput,
    platform = @platformInput
where mediaItemID = @mediaItemIDInput;

-- Update a SportsEvent
update SportsEvents
set
    typeOfSport = @typeOfSportInput,
    homeTeam = @homeTeamInput,
    awayTeam = @awayTeamInput,
    startTime = @startTimeInput,
    runtimeMins = @runtimeMinsInput,
    recordingIsAvailable = @recordingIsAvailableInput,
    platform = @platformInput
where sportsEventID = @sportsEventIDInput;

-- Update a UserTrackerEntry
update UserTrackerEntries
set
    status = @statusInput,
    completedAt = @completedAtInput
where entryID = @entryIDInput;

--- DELETE ---

-- Delete a UserTrackerEntry
delete from UserTrackerEntries
where entryID = @entryIDInput;

-- Delete a MediaItem
delete from MediaItems
where mediaItemID = @mediaItemIDInput;

-- Delete a SportsEvent
delete from SportsEvents
where sportsEventID = @sportsEventIDInput;

-- Delete a User
delete from Users
where userID = @userIDInput;