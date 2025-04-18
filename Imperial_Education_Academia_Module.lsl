// Imperial Russian Court Roleplay System
// Script: Imperial Education and Academia Module
// Version: 1.0
// Description: Module for education, academic standing, and intellectual pursuits

// Constants
key TSAR_UUID = "49238f92-08a4-4f72-bca4-e66a15c75e02"; // Tsar Nikolai II
key ZAREVICH_UUID = "707c2fdf-6f8a-43c9-a5fb-3debc0941064"; // Zarevich Alexei

// Communication channels
integer MAIN_CHANNEL = -8675309;  // Main system channel
integer STATS_CHANNEL = -8675310; // Channel for stats updates
integer EDUCATION_CHANNEL = -8675333; // Specific channel for education module

// Education levels
integer EDU_NONE = 0;           // No formal education
integer EDU_BASIC = 1;          // Basic education
integer EDU_SECONDARY = 2;      // Secondary education
integer EDU_UNIVERSITY = 3;     // University education
integer EDU_ADVANCED = 4;       // Advanced degrees

// Academic positions
integer POS_NONE = 0;           // No academic position
integer POS_STUDENT = 1;        // Student
integer POS_INSTRUCTOR = 2;     // Instructor/Lecturer
integer POS_PROFESSOR = 3;      // Professor
integer POS_DEPARTMENT = 4;     // Department Chair/Dean
integer POS_ACADEMY = 5;        // Academy of Sciences Member

// Fields of study
integer FIELD_GENERAL = 0;      // General education
integer FIELD_MILITARY = 1;     // Military sciences
integer FIELD_LAW = 2;          // Law/Jurisprudence
integer FIELD_MEDICINE = 3;     // Medicine
integer FIELD_SCIENCE = 4;      // Natural sciences
integer FIELD_HUMANITIES = 5;   // Humanities/Arts
integer FIELD_LINGUISTICS = 6;  // Languages/Linguistics
integer FIELD_THEOLOGY = 7;     // Theology/Religious studies
integer FIELD_ECONOMICS = 8;    // Economics/Finance

// Status variables
integer educationLevel = EDU_NONE;
integer academicPosition = POS_NONE;
integer fieldOfStudy = FIELD_GENERAL;
string institution = "None";
string specialization = "None";
string languages = "Russian";
list publications = [];
list academicEvents = [];      // Lectures, symposiums attended
list academicAwards = [];      // Academic honors received
integer intellectScore = 0;    // 0-100 intellectual ability
integer isActive = FALSE;      // Is module active
integer listenHandle;          // Handle for the listen event

// Function to check if an avatar is the Tsar
integer isTsar(key avatarKey) {
    return (avatarKey == TSAR_UUID);
}

// Function to check if an avatar is the Zarevich
integer isZarevich(key avatarKey) {
    return (avatarKey == ZAREVICH_UUID);
}

// Function to set education level
setEducationLevel(integer level) {
    educationLevel = level;
    
    // Apply effects of education level
    if (level >= EDU_UNIVERSITY) {
        // University education or higher grants base intellectual score
        intellectScore = llMax(intellectScore, 60);
    }
    else if (level == EDU_SECONDARY) {
        intellectScore = llMax(intellectScore, 40);
    }
    else if (level == EDU_BASIC) {
        intellectScore = llMax(intellectScore, 20);
    }
    
    // Update module display
    updateModuleDisplay();
    
    // Announce education change
    string levelName = getEducationLevelName(level);
    llSay(0, "Education level set to: " + levelName);
}

// Function to set academic position
setAcademicPosition(integer position) {
    academicPosition = position;
    
    // Apply effects of academic position
    if (position >= POS_PROFESSOR) {
        // Professors and higher positions require university education
        educationLevel = llMax(educationLevel, EDU_UNIVERSITY);
        intellectScore = llMax(intellectScore, 75);
    }
    else if (position == POS_INSTRUCTOR) {
        educationLevel = llMax(educationLevel, EDU_UNIVERSITY);
        intellectScore = llMax(intellectScore, 65);
    }
    else if (position == POS_STUDENT) {
        // Students must have at least basic education
        educationLevel = llMax(educationLevel, EDU_BASIC);
    }
    
    // Update module display
    updateModuleDisplay();
    
    // Announce position change
    string positionName = getAcademicPositionName(position);
    llSay(0, "Academic position set to: " + positionName);
}

// Function to set field of study
setFieldOfStudy(integer field) {
    fieldOfStudy = field;
    
    // Update module display
    updateModuleDisplay();
    
    // Announce field change
    string fieldName = getFieldOfStudyName(field);
    llSay(0, "Field of study set to: " + fieldName);
}

// Function to set educational institution
setInstitution(string inst) {
    institution = inst;
    
    // Update module display
    updateModuleDisplay();
    
    // Announce institution change
    llSay(0, "Educational institution set to: " + inst);
}

// Function to set specialization
setSpecialization(string spec) {
    specialization = spec;
    
    // Update module display
    updateModuleDisplay();
    
    // Announce specialization change
    llSay(0, "Specialization set to: " + spec);
}

// Function to set known languages
setLanguages(string langs) {
    languages = langs;
    
    // Update intellectual score based on languages
    // Count commas to estimate number of languages
    integer numLanguages = 1;
    integer i;
    for (i = 0; i < llStringLength(langs); i++) {
        if (llGetSubString(langs, i, i) == ",") {
            numLanguages++;
        }
    }
    
    // Each language beyond Russian adds 5 points
    intellectScore = llMin(100, intellectScore + ((numLanguages - 1) * 5));
    
    // Update module display
    updateModuleDisplay();
    
    // Announce languages change
    llSay(0, "Known languages set to: " + langs);
}

// Function to add a publication
addPublication(string title) {
    publications += [title];
    
    // Update intellectual score
    intellectScore = llMin(100, intellectScore + 3);
    
    // Update module display
    updateModuleDisplay();
    
    // Announce publication
    llSay(0, "Published academic work: " + title);
}

// Function to add an academic event
addAcademicEvent(string event) {
    academicEvents += [event];
    
    // Update intellectual score
    intellectScore = llMin(100, intellectScore + 1);
    
    // Limit list size
    if (llGetListLength(academicEvents) > 10) {
        academicEvents = llDeleteSubList(academicEvents, 0, 0);
    }
    
    // Update module display
    updateModuleDisplay();
    
    // Announce event
    llSay(0, "Participated in academic event: " + event);
}

// Function to add an academic award
addAcademicAward(string award) {
    academicAwards += [award];
    
    // Update intellectual score
    intellectScore = llMin(100, intellectScore + 5);
    
    // Update module display
    updateModuleDisplay();
    
    // Announce award
    llSay(0, "Received academic award: " + award);
}

// Function to conduct research
conductResearch(string topic) {
    // Check if qualified for research
    if (educationLevel < EDU_UNIVERSITY) {
        llSay(0, "You need at least university education to conduct formal research.");
        return;
    }
    
    // Announce research
    llSay(0, "Beginning research on: " + topic);
    
    // Calculate success chance based on education and intellect
    integer baseChance = 50;
    integer eduBonus = (educationLevel - EDU_UNIVERSITY) * 10;
    integer intBonus = intellectScore / 5;
    integer finalChance = llMin(95, baseChance + eduBonus + intBonus);
    
    // Roll for success
    integer roll = llFloor(llFrand(100));
    integer success = (roll < finalChance);
    
    // Create appropriate result message
    string resultMessage = "";
    if (success) {
        // Successful research
        resultMessage = "Your research on '" + topic + "' has yielded valuable insights.\n";
        
        // Bonus based on field of study
        if (fieldOfStudy != FIELD_GENERAL) {
            resultMessage += "Your expertise in " + getFieldOfStudyName(fieldOfStudy) + " was particularly valuable.\n";
        }
        
        resultMessage += "\nYou may now present your findings or publish a paper on this topic.";
        
        // Small intellectual boost
        intellectScore = llMin(100, intellectScore + 2);
    }
    else {
        // Unsuccessful research
        resultMessage = "Your research on '" + topic + "' has not yielded significant results.\n";
        resultMessage += "Further study may be required to make progress in this area.";
    }
    
    // Show result to researcher
    llSay(0, resultMessage);
    
    // Update display
    updateModuleDisplay();
}

// Function to give a lecture
giveLecture(string topic) {
    // Check if qualified to lecture
    if (academicPosition < POS_INSTRUCTOR) {
        llSay(0, "You need to be at least an Instructor to give formal lectures.");
        return;
    }
    
    // Announce lecture
    llSay(0, llKey2Name(llGetOwner()) + " is giving a lecture on: " + topic);
    
    // Calculate success based on academic position and intellect
    integer baseChance = 60;
    integer posBonus = academicPosition * 5;
    integer intBonus = intellectScore / 4;
    integer finalChance = llMin(95, baseChance + posBonus + intBonus);
    
    // Roll for success
    integer roll = llFloor(llFrand(100));
    integer success = (roll < finalChance);
    
    // Create appropriate result message
    string resultMessage = "";
    if (success) {
        // Successful lecture
        resultMessage = "Your lecture on '" + topic + "' was well-received.\n";
        
        // Extra effects based on position
        if (academicPosition >= POS_PROFESSOR) {
            resultMessage += "As a distinguished academic, your insights were particularly valued.\n";
        }
        
        resultMessage += "\nYour academic reputation has been enhanced.";
        
        // Small intellectual boost
        intellectScore = llMin(100, intellectScore + 1);
        
        // Add to academic events
        addAcademicEvent("Lecture on " + topic);
    }
    else {
        // Unsuccessful lecture
        resultMessage = "Your lecture on '" + topic + "' received a lukewarm response.\n";
        resultMessage += "Perhaps a different approach would be more effective next time.";
    }
    
    // Show result to lecturer
    llSay(0, resultMessage);
    
    // Update display
    updateModuleDisplay();
}

// Function to attend a class
attendClass(string subject) {
    // Anyone can attend a class
    
    // Announce class attendance
    llSay(0, llKey2Name(llGetOwner()) + " is attending a class on: " + subject);
    
    // Calculate learning benefits based on education level and intellect
    integer baseGain = 1;
    integer eduBonus = educationLevel;
    integer intBonus = intellectScore / 20;
    integer totalGain = baseGain + eduBonus + intBonus;
    
    // Apply learning benefits
    intellectScore = llMin(100, intellectScore + totalGain);
    
    // Add to academic events
    addAcademicEvent("Class on " + subject);
    
    // Show result
    llSay(0, "You have gained knowledge from the class on '" + subject + "'.");
    llSay(0, "Intellectual ability increased by " + (string)totalGain + " points.");
    
    // Update display
    updateModuleDisplay();
}

// Function to join the Academy of Sciences
joinAcademy() {
    // Check eligibility
    if (educationLevel < EDU_ADVANCED) {
        llSay(0, "You need advanced education to be considered for the Academy of Sciences.");
        return;
    }
    
    if (intellectScore < 80) {
        llSay(0, "Your intellectual achievements are not yet sufficient for the Academy of Sciences.");
        return;
    }
    
    if (llGetListLength(publications) < 3) {
        llSay(0, "You need more published works to be considered for the Academy of Sciences.");
        return;
    }
    
    // Calculate acceptance chance
    integer baseChance = 30; // Academy membership is prestigious and difficult
    integer intBonus = (intellectScore - 80) / 2;
    integer pubBonus = llGetListLength(publications) * 5;
    integer finalChance = llMin(90, baseChance + intBonus + pubBonus);
    
    // Roll for success
    integer roll = llFloor(llFrand(100));
    integer success = (roll < finalChance);
    
    if (success) {
        // Accepted to Academy
        setAcademicPosition(POS_ACADEMY);
        
        // Add award
        addAcademicAward("Member of the Imperial Academy of Sciences");
        
        llSay(0, "Congratulations! You have been accepted as a member of the Imperial Academy of Sciences.");
        llSay(0, "This prestigious honor recognizes your exceptional intellectual contributions.");
    }
    else {
        // Rejected from Academy
        llSay(0, "The Imperial Academy of Sciences has reviewed your application.");
        llSay(0, "Unfortunately, they have decided not to extend membership at this time.");
        llSay(0, "You may apply again after further academic achievements.");
    }
}

// Helper function to get education level name
string getEducationLevelName(integer level) {
    if (level == EDU_NONE) {
        return "None";
    }
    else if (level == EDU_BASIC) {
        return "Basic Education";
    }
    else if (level == EDU_SECONDARY) {
        return "Secondary Education";
    }
    else if (level == EDU_UNIVERSITY) {
        return "University Education";
    }
    else if (level == EDU_ADVANCED) {
        return "Advanced Degree";
    }
    return "Unknown";
}

// Helper function to get academic position name
string getAcademicPositionName(integer position) {
    if (position == POS_NONE) {
        return "None";
    }
    else if (position == POS_STUDENT) {
        return "Student";
    }
    else if (position == POS_INSTRUCTOR) {
        return "Instructor";
    }
    else if (position == POS_PROFESSOR) {
        return "Professor";
    }
    else if (position == POS_DEPARTMENT) {
        return "Department Chair";
    }
    else if (position == POS_ACADEMY) {
        return "Academy Member";
    }
    return "Unknown";
}

// Helper function to get field of study name
string getFieldOfStudyName(integer field) {
    if (field == FIELD_GENERAL) {
        return "General Studies";
    }
    else if (field == FIELD_MILITARY) {
        return "Military Sciences";
    }
    else if (field == FIELD_LAW) {
        return "Law";
    }
    else if (field == FIELD_MEDICINE) {
        return "Medicine";
    }
    else if (field == FIELD_SCIENCE) {
        return "Natural Sciences";
    }
    else if (field == FIELD_HUMANITIES) {
        return "Humanities";
    }
    else if (field == FIELD_LINGUISTICS) {
        return "Linguistics";
    }
    else if (field == FIELD_THEOLOGY) {
        return "Theology";
    }
    else if (field == FIELD_ECONOMICS) {
        return "Economics";
    }
    return "Unknown";
}

// Function to update module display
updateModuleDisplay() {
    if (!isActive) {
        llSetText("", <0,0,0>, 0);
        return;
    }
    
    string displayText = "Education & Academia\n";
    
    // Show education level
    string levelName = getEducationLevelName(educationLevel);
    displayText += "Education: " + levelName + "\n";
    
    // Show academic position if any
    if (academicPosition != POS_NONE) {
        string positionName = getAcademicPositionName(academicPosition);
        displayText += "Position: " + positionName + "\n";
    }
    
    // Show field of study if not general
    if (fieldOfStudy != FIELD_GENERAL) {
        string fieldName = getFieldOfStudyName(fieldOfStudy);
        displayText += "Field: " + fieldName + "\n";
    }
    
    // Show institution if any
    if (institution != "None") {
        displayText += "Institution: " + institution + "\n";
    }
    
    // Show specialization if any
    if (specialization != "None") {
        displayText += "Specialty: " + specialization + "\n";
    }
    
    // Show intellectual score
    displayText += "Intellect: " + (string)intellectScore + "/100";
    
    // Set the text with appropriate color
    vector textColor = <0.7, 0.9, 1.0>; // Light blue for education
    llSetText(displayText, textColor, 1.0);
}

// Process commands from other system components
processEducationCommand(string message, key senderKey) {
    list messageParts = llParseString2List(message, ["|"], []);
    string command = llList2String(messageParts, 0);
    
    if (command == "EDUCATION_SET") {
        // Format: EDUCATION_SET|level
        if (llGetListLength(messageParts) >= 2) {
            integer level = (integer)llList2String(messageParts, 1);
            setEducationLevel(level);
        }
    }
    else if (command == "POSITION_SET") {
        // Format: POSITION_SET|position
        if (llGetListLength(messageParts) >= 2) {
            integer position = (integer)llList2String(messageParts, 1);
            setAcademicPosition(position);
        }
    }
    else if (command == "FIELD_SET") {
        // Format: FIELD_SET|field
        if (llGetListLength(messageParts) >= 2) {
            integer field = (integer)llList2String(messageParts, 1);
            setFieldOfStudy(field);
        }
    }
    else if (command == "INSTITUTION_SET") {
        // Format: INSTITUTION_SET|name
        if (llGetListLength(messageParts) >= 2) {
            string inst = llList2String(messageParts, 1);
            setInstitution(inst);
        }
    }
    else if (command == "SPECIALIZATION_SET") {
        // Format: SPECIALIZATION_SET|name
        if (llGetListLength(messageParts) >= 2) {
            string spec = llList2String(messageParts, 1);
            setSpecialization(spec);
        }
    }
    else if (command == "LANGUAGES_SET") {
        // Format: LANGUAGES_SET|languages
        if (llGetListLength(messageParts) >= 2) {
            string langs = llList2String(messageParts, 1);
            setLanguages(langs);
        }
    }
    else if (command == "PUBLICATION_ADD") {
        // Format: PUBLICATION_ADD|title
        if (llGetListLength(messageParts) >= 2) {
            string title = llList2String(messageParts, 1);
            addPublication(title);
        }
    }
    else if (command == "EVENT_ADD") {
        // Format: EVENT_ADD|description
        if (llGetListLength(messageParts) >= 2) {
            string event = llList2String(messageParts, 1);
            addAcademicEvent(event);
        }
    }
    else if (command == "AWARD_ADD") {
        // Format: AWARD_ADD|description
        if (llGetListLength(messageParts) >= 2) {
            string award = llList2String(messageParts, 1);
            addAcademicAward(award);
        }
    }
    else if (command == "RESEARCH_CONDUCT") {
        // Format: RESEARCH_CONDUCT|topic
        if (llGetListLength(messageParts) >= 2) {
            string topic = llList2String(messageParts, 1);
            conductResearch(topic);
        }
    }
    else if (command == "LECTURE_GIVE") {
        // Format: LECTURE_GIVE|topic
        if (llGetListLength(messageParts) >= 2) {
            string topic = llList2String(messageParts, 1);
            giveLecture(topic);
        }
    }
    else if (command == "CLASS_ATTEND") {
        // Format: CLASS_ATTEND|subject
        if (llGetListLength(messageParts) >= 2) {
            string subject = llList2String(messageParts, 1);
            attendClass(subject);
        }
    }
    else if (command == "ACADEMY_JOIN") {
        joinAcademy();
    }
    else if (command == "ACTIVATE") {
        isActive = TRUE;
        updateModuleDisplay();
    }
    else if (command == "DEACTIVATE") {
        isActive = FALSE;
        llSetText("", <0,0,0>, 0);
    }
}

default {
    state_entry() {
        // Start listening for system events
        listenHandle = llListen(EDUCATION_CHANNEL, "", NULL_KEY, "");
        
        // Update display
        updateModuleDisplay();
    }
    
    touch_start(integer num_detected) {
        key toucherKey = llDetectedKey(0);
        
        // Main menu options
        list options = [
            "Education",
            "Academic Position",
            "Field of Study",
            "Languages",
            "Academic Activities",
            "View Achievements"
        ];
        
        // Show menu
        llDialog(toucherKey, "Education and Academia Module", options, EDUCATION_CHANNEL);
    }
    
    listen(integer channel, string name, key id, string message) {
        // Process main menu selections
        if (channel == EDUCATION_CHANNEL) {
            if (message == "Education") {
                // Show education options
                list eduOptions = [
                    "No Formal Education",
                    "Basic Education",
                    "Secondary Education",
                    "University",
                    "Advanced Degree"
                ];
                llDialog(id, "Select your education level:", eduOptions, EDUCATION_CHANNEL + 1);
            }
            else if (message == "Academic Position") {
                // Show position options
                list posOptions = [
                    "None",
                    "Student",
                    "Instructor",
                    "Professor",
                    "Department Chair"
                ];
                
                // Add Academy option if qualified
                if (educationLevel >= EDU_ADVANCED && intellectScore >= 80) {
                    posOptions += ["Apply to Academy"];
                }
                
                llDialog(id, "Select academic position:", posOptions, EDUCATION_CHANNEL + 2);
            }
            else if (message == "Field of Study") {
                // Show field options
                list fieldOptions = [
                    "General Studies",
                    "Military Sciences",
                    "Law",
                    "Medicine",
                    "Natural Sciences",
                    "Humanities",
                    "Linguistics",
                    "Theology",
                    "Economics"
                ];
                llDialog(id, "Select field of study:", fieldOptions, EDUCATION_CHANNEL + 3);
            }
            else if (message == "Languages") {
                // Show language options
                list langOptions = [
                    "Russian only",
                    "Add French",
                    "Add German",
                    "Add English",
                    "Add Latin",
                    "Add Greek"
                ];
                llDialog(id, "Select known languages:", langOptions, EDUCATION_CHANNEL + 4);
            }
            else if (message == "Academic Activities") {
                // Show activity options
                list activityOptions = [
                    "Conduct Research",
                    "Give Lecture",
                    "Attend Class",
                    "Publish Paper",
                    "Educational Institution"
                ];
                llDialog(id, "Select academic activity:", activityOptions, EDUCATION_CHANNEL + 5);
            }
            else if (message == "View Achievements") {
                // Compile achievements information
                string achieveInfo = "Academic Achievements:\n\n";
                
                // Education details
                string levelName = getEducationLevelName(educationLevel);
                achieveInfo += "Education Level: " + levelName + "\n";
                
                if (academicPosition != POS_NONE) {
                    string positionName = getAcademicPositionName(academicPosition);
                    achieveInfo += "Academic Position: " + positionName + "\n";
                }
                
                if (fieldOfStudy != FIELD_GENERAL) {
                    string fieldName = getFieldOfStudyName(fieldOfStudy);
                    achieveInfo += "Field of Study: " + fieldName + "\n";
                }
                
                if (specialization != "None") {
                    achieveInfo += "Specialization: " + specialization + "\n";
                }
                
                if (institution != "None") {
                    achieveInfo += "Institution: " + institution + "\n";
                }
                
                achieveInfo += "Languages: " + languages + "\n";
                achieveInfo += "Intellectual Score: " + (string)intellectScore + "/100\n\n";
                
                // Publications
                integer pubCount = llGetListLength(publications);
                if (pubCount > 0) {
                    achieveInfo += "Publications (" + (string)pubCount + "):\n";
                    
                    integer i;
                    for (i = 0; i < pubCount; i++) {
                        achieveInfo += "- " + llList2String(publications, i) + "\n";
                    }
                    achieveInfo += "\n";
                }
                
                // Academic awards
                integer awardCount = llGetListLength(academicAwards);
                if (awardCount > 0) {
                    achieveInfo += "Academic Honors:\n";
                    
                    integer i;
                    for (i = 0; i < awardCount; i++) {
                        achieveInfo += "- " + llList2String(academicAwards, i) + "\n";
                    }
                    achieveInfo += "\n";
                }
                
                // Recent events
                integer eventCount = llGetListLength(academicEvents);
                if (eventCount > 0) {
                    achieveInfo += "Recent Academic Activities:\n";
                    
                    integer i;
                    for (i = 0; i < eventCount; i++) {
                        achieveInfo += "- " + llList2String(academicEvents, i) + "\n";
                    }
                }
                
                // Show the achievements dialog
                llDialog(id, achieveInfo, ["Return to Main Menu"], EDUCATION_CHANNEL);
            }
            else {
                // Check if it's a system command
                processEducationCommand(message, id);
            }
        }
        else if (channel == EDUCATION_CHANNEL + 1) {
            // Process education level selection
            if (message == "No Formal Education") {
                setEducationLevel(EDU_NONE);
            }
            else if (message == "Basic Education") {
                setEducationLevel(EDU_BASIC);
            }
            else if (message == "Secondary Education") {
                setEducationLevel(EDU_SECONDARY);
            }
            else if (message == "University") {
                setEducationLevel(EDU_UNIVERSITY);
            }
            else if (message == "Advanced Degree") {
                setEducationLevel(EDU_ADVANCED);
            }
        }
        else if (channel == EDUCATION_CHANNEL + 2) {
            // Process academic position selection
            if (message == "None") {
                setAcademicPosition(POS_NONE);
            }
            else if (message == "Student") {
                setAcademicPosition(POS_STUDENT);
            }
            else if (message == "Instructor") {
                setAcademicPosition(POS_INSTRUCTOR);
            }
            else if (message == "Professor") {
                setAcademicPosition(POS_PROFESSOR);
            }
            else if (message == "Department Chair") {
                setAcademicPosition(POS_DEPARTMENT);
            }
            else if (message == "Apply to Academy") {
                joinAcademy();
            }
        }
        else if (channel == EDUCATION_CHANNEL + 3) {
            // Process field of study selection
            if (message == "General Studies") {
                setFieldOfStudy(FIELD_GENERAL);
            }
            else if (message == "Military Sciences") {
                setFieldOfStudy(FIELD_MILITARY);
            }
            else if (message == "Law") {
                setFieldOfStudy(FIELD_LAW);
            }
            else if (message == "Medicine") {
                setFieldOfStudy(FIELD_MEDICINE);
            }
            else if (message == "Natural Sciences") {
                setFieldOfStudy(FIELD_SCIENCE);
            }
            else if (message == "Humanities") {
                setFieldOfStudy(FIELD_HUMANITIES);
            }
            else if (message == "Linguistics") {
                setFieldOfStudy(FIELD_LINGUISTICS);
            }
            else if (message == "Theology") {
                setFieldOfStudy(FIELD_THEOLOGY);
            }
            else if (message == "Economics") {
                setFieldOfStudy(FIELD_ECONOMICS);
            }
        }
        else if (channel == EDUCATION_CHANNEL + 4) {
            // Process language selection
            if (message == "Russian only") {
                setLanguages("Russian");
            }
            else if (message == "Add French") {
                setLanguages(languages + ", French");
            }
            else if (message == "Add German") {
                setLanguages(languages + ", German");
            }
            else if (message == "Add English") {
                setLanguages(languages + ", English");
            }
            else if (message == "Add Latin") {
                setLanguages(languages + ", Latin");
            }
            else if (message == "Add Greek") {
                setLanguages(languages + ", Greek");
            }
        }
        else if (channel == EDUCATION_CHANNEL + 5) {
            // Process academic activity selection
            if (message == "Conduct Research") {
                // Ask for research topic
                llTextBox(id, "Enter research topic:", EDUCATION_CHANNEL + 6);
            }
            else if (message == "Give Lecture") {
                // Ask for lecture topic
                llTextBox(id, "Enter lecture topic:", EDUCATION_CHANNEL + 7);
            }
            else if (message == "Attend Class") {
                // Show class options
                list classOptions = [
                    "History",
                    "Literature",
                    "Philosophy",
                    "Mathematics",
                    "Sciences",
                    "Languages",
                    "Law",
                    "Military Strategy"
                ];
                llDialog(id, "Select class subject:", classOptions, EDUCATION_CHANNEL + 8);
            }
            else if (message == "Publish Paper") {
                // Ask for paper title
                llTextBox(id, "Enter paper title:", EDUCATION_CHANNEL + 9);
            }
            else if (message == "Educational Institution") {
                // Show institution options
                list instOptions = [
                    "University of Moscow",
                    "University of St. Petersburg",
                    "Imperial Military Academy",
                    "Imperial School of Law",
                    "Imperial Medical Academy",
                    "Smolny Institute",
                    "Theological Seminary"
                ];
                llDialog(id, "Select your institution:", instOptions, EDUCATION_CHANNEL + 10);
            }
        }
        else if (channel == EDUCATION_CHANNEL + 6) {
            // Process research topic
            if (message != "") {
                conductResearch(message);
            }
        }
        else if (channel == EDUCATION_CHANNEL + 7) {
            // Process lecture topic
            if (message != "") {
                giveLecture(message);
            }
        }
        else if (channel == EDUCATION_CHANNEL + 8) {
            // Process class selection
            if (message != "") {
                attendClass(message);
            }
        }
        else if (channel == EDUCATION_CHANNEL + 9) {
            // Process paper publication
            if (message != "") {
                // Check if qualified to publish
                if (educationLevel < EDU_UNIVERSITY) {
                    llRegionSayTo(id, 0, "You need at least university education to publish academic papers.");
                    return;
                }
                
                addPublication(message);
            }
        }
        else if (channel == EDUCATION_CHANNEL + 10) {
            // Process institution selection
            if (message != "") {
                setInstitution(message);
                
                // Set appropriate field based on institution
                if (message == "Imperial Military Academy") {
                    setFieldOfStudy(FIELD_MILITARY);
                }
                else if (message == "Imperial School of Law") {
                    setFieldOfStudy(FIELD_LAW);
                }
                else if (message == "Imperial Medical Academy") {
                    setFieldOfStudy(FIELD_MEDICINE);
                }
                else if (message == "Theological Seminary") {
                    setFieldOfStudy(FIELD_THEOLOGY);
                }
            }
        }
    }
}