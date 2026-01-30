-- this is our origional work no AI or external resources were used
-- find a way to constrain so you have either a mediaItemID or sportsEventID but not both
-- do varchars need to have a specified size such as varchar(255) or can it be just varchar?

-- Stores information about the app's users
create or replace table Users
(
    userID      int not null auto_increment,
    primary key (userID),
    username    varchar not null unique,
    email       varchar not null
);

-- Stores information about movies, TV shows, and books
create or replace table MediaItems
(
    mediaItemID int not null auto_increment,
    primary key (mediaItemID),
    mediaType   enum('MOVIE','SHOW','BOOK') not null,
    title       varchar not null,
    releaseDate datetime,
    runtimeMins int,
    creator     varchar,
    platform    varchar
);

-- Stores information about scheduled sports events
create or replace table SportsEvents
(
    sportsEventID           int not null auto_increment,
    primary key             (sportsEventID),
    typeOfSport             varchar  not null,
    homeTeam                varchar  not null,
    awayTeam                varchar  not null,
    startTime               datetime not null,
    runtimeMins             int,
    recordingIsAvailable    boolean,
    platform                varchar
);

-- Stores information about a particular user’s tracking relationship with a specific media or sports event
create or replace table UserTrackerEntries
(
    entryID         int not null auto_increment,
    primary key     (entryID),
    userID          int not null,
    foreign key     (userID)        references Users(userID),

    -- find a way to constrain so you have either a mediaItemID or sportsEventID but not both
    mediaItemID     int,
    foreign key     (mediaItemID)   references MediaItems(mediaItemID),
    sportsEventID   int,
    foreign key     (sportsEventID) references SportsEvents(sportsEventID),

    status          enum('TO_WATCH','WATCHING','WATCHED'),
    savedAt         datetime not null,
    completedAt     datetime
);