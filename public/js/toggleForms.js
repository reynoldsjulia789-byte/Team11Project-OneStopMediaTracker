/*     
    CS 340 – Introduction to Databases
    Project Step 3 Draft – Design UI Interface + DML SQL
    Project: NextUp – A One-Stop Media Tracker
    Group 11: Julia Reynolds, Stephen Stanwood

    File: toggleForms.js

    AI used to implement form toggling and autofill the edit form.
    Date: 2/17/2026

    Prompt 1:
    How can I make the Add form on each page appear when the addButton is clicked and hidden otherwise?
    Would it also be possible to hide the add button when the form is visible?
    Please wait to implement any code until after explaining to me how the code works.

    Pompt 2:
    Thank you. Can the same thing be done, but for the edit buttons and the Update forms?
    Also, would it be possible to auto-fill the update form with the information in the row corresponding to the edit button? 
    Is it possible to make it so the edit button is not hidden when the Update form is shown? I still want the add button to be hidden when the form is shown.
    Please wait to implement any code until after explaining to me how the code works.

    Code reviewed and edited by Julia Reynolds after AI's creation.
    Add button currently not hiding when form is open.
    Will work on a solution.
*/     


document.addEventListener('DOMContentLoaded', () => 
{
        document.querySelectorAll('.addButton').forEach(btn => 
        {
            const targetId = btn.dataset.target;
            const target   = targetId ? document.getElementById(targetId) : null;

            if (!btn.hasAttribute('aria-expanded'))
            {
                btn.setAttribute('aria-expanded', 'false');
            }

            btn.addEventListener('click', () => 
                {
                    if (!target)
                    {
                        return;
                    }
                    
                    target.classList.remove('hidden');
                    
                    btn.classList.add('hidden');
                    btn.setAttribute('aria-expanded', 'true');
                });

            if (target)
            {
                // when a done or cancel control is clicked, hide the form and show the add button
                target.querySelectorAll('button.doneButton, button.cancelButton').forEach(ctrl =>
                {
                    ctrl.addEventListener('click', () =>
                    {
                        target.classList.add('hidden');
                        btn.classList.remove('hidden');
                        btn.setAttribute('aria-expanded', 'false');
                    });
                });
            }
        });
  
    // Edit buttons: show update form and autofill fields from the row
    const fillMappings =
    {
        updateUserForm:    { userID: 0, username: 1, email: 2 },
        updateMediaForm:   { mediaItemID: 0, mediaType: 1, title: 2, releaseDate: 3, runtimeMins: 4, creator: 5, platform: 6 },
        updateSportsForm:  { sportsEventID: 0, typeOfSport: 1, homeTeam: 2, awayTeam: 3, startTime: 4, runtimeMins: 5, recordingIsAvailable: 6, platform: 7 },
        updateTrackerForm: { entryID: 0, status: 4, completedAt: 6 }
    };

    document.querySelectorAll('.editButton').forEach(btn => 
    {
        const targetId = btn.dataset.editTarget;
        const target   = targetId ? document.getElementById(targetId) : null;
        if (!btn.hasAttribute('aria-expanded')) btn.setAttribute('aria-expanded', 'false');

        btn.addEventListener('click', () =>
        {
            if (!target)
            {
                return;
            }
            // show form (do not hide the edit button)
            target.classList.remove('hidden');
            btn.setAttribute('aria-expanded', 'true');

            // autofill from the row
            const row = btn.closest('tr');
            if (row)
            {
                const cells = Array.from(row.querySelectorAll('td')).map(td => td.textContent.trim());
                const mapping = fillMappings[targetId];
                if (mapping)
                {
                    Object.entries(mapping).forEach(([name, idx]) =>
                    {
                        const input = target.querySelector(`[name="${name}"]`);
                        
                        if (!input)
                        {
                            return;
                        }

                        let value = cells[idx] ?? '';

                        if (value === 'null')
                        {
                            value = '';
                        }

                        // normalize datetime format (YYYY-MM-DD HH:MM -> YYYY-MM-DDTHH:MM) for datetime-local
                        if (input.type === 'datetime-local' && value)
                        {
                            value = value.replace(' ', 'T');
                        }
                        if (input.tagName === 'SELECT')
                        {
                            // try to match by option value or text
                            Array.from(input.options).forEach(opt =>
                            {
                                if (opt.value === value || opt.text === value) opt.selected = true;
                            });
                        } 
                        else
                        {
                            input.value = value;
                        }
                    });
                }
            }

            // restore on done/cancel (hide the form; keep edit button visible)
            if (target)
            {
                target.querySelectorAll('button.doneButton, button.cancelButton').forEach(ctrl =>
                {
                    ctrl.addEventListener('click', () =>
                    {
                        target.classList.add('hidden');
                        btn.setAttribute('aria-expanded', 'false');
                    });
                });
            }
        });
    });
});
