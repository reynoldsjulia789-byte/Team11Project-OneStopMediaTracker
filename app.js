/*
CS 340 – Introduction to Databases
Project Step 3 Draft – Design UI Interface + DML SQL
Project: NextUp – A One-Stop Media Tracker
Group 11: Julia Reynolds, Stephen Stanwood

File: app.js
Purpose: Set up a simple server + routes for viewing database via simple UI.

Original work. No AI or external resources were used.
*/


/*
    SETUP
*/

const express = require('express');

// use Handlebars for templating (as suggested in Step 3)
const exphbs = require('express-handlebars');

const app = express();
const PORT = 9124;

// set up Handlebars for templating
app.engine('.hbs', exphbs.engine({ extname: '.hbs' }));
app.set('view engine', '.hbs');
app.set('views', './views');

// set up middleware
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(express.static('public'));


/*
    ROUTES
*/

// Home / index page
app.get('/', (req, res) => {
    res.render('index');
});

// One page per table (Step 3 rubric)
app.get('/users', (req, res) => {
    res.render('users');
});

app.get('/media-items', (req, res) => {
    res.render('media-items');
});

app.get('/sports-events', (req, res) => {
    res.render('sports-events');
});

app.get('/tracker-entries', (req, res) => {
    res.render('tracker-entries');
});


/*
    LISTENER
*/

app.listen(PORT, () => {
    console.log(`Express started on http://classwork.engr.oregonstate.edu:${PORT}`);
});