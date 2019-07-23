#best when run in system command line

from random import randint, shuffle
import smtplib
import re
from os import system, name as osname
from getpass import getpass

#dictionary to store all information
names = {}

#creates the dictionary of information from user input
def createDict():
    #imports names variable
    global names
    
    exits = ['bye','done','exit','Exit']

    #while user hasn't called end
    check = True
    while check:
        #input name
        nameCheck = True
        while nameCheck:
            name = input("Name: ")
            if name in exits:
                nameCheck = False
                check = False
            elif name in names:
                print("Please try again")
            elif name == '':
                print("Please try again")
            else:
                nameCheck = False

        #input email
        if check:
            emailCheck = True
            while emailCheck:
                email = input('Email: ')
                if email == '':
                    print("Please try again")
                elif email in exits:
                    emailCheck = False
                    check = False
                elif bool(re.match(r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)",email)) != True:
                    print("Invalid email. Please try again.")
                else:
                    emailCheck = False

        #input skips
        if check:
            skipsCheck = True
            while skipsCheck:
                skips = input("Skips: ")
                if skips in exits:
                    skipsCheck = False
                    check = False
                elif skips == '':
                    skipsList = []
                    skipsCheck = False
                else:
                    skipsList = [element.strip() for element in skips.split(",")]
                    skipsCheck = False
        
        if check:
            #create dictionary entry
            names[name] = {'skips':skipsList, 'email': email, 'giftee':''}

def secretSanta():
    global names
    #dictionary to keep track of pairs
    pairs = {}
    #list to keep track of who's already been selected
    used = []
    
    #list of names shuffled
    keys = list(names.keys())
    shuffle(keys)
    
    #for each name in shuffled order
    for name in keys:
        #creates a set to keep track of unavailalbe options
        tempUsed = {name}
        for i in used: 
            tempUsed.add(i)
        for i in names[name]['skips']: 
            tempUsed.add(i)

        #inverts the list to get available options
        options = [name for name in keys if name not in tempUsed]
        
        #if there are no options, run secretSanta again
        if len(options) == 0:
            secretSanta()
        #else, random select a name, add it to pairs and used
        else:
            tempName = options[randint(0,len(options)-1)]
            pairs[name] = tempName
            used.append(tempName)
    
    #once pairs have been selected, updates names dictionary    
    for name in pairs:
       names[name]['giftee'] = pairs[name]
  
def email():
    #imports useful variables
    global names
    global mainLoop
    
    #counter to keep track of password attempts
    counter = 0
    while counter < 5:
        usr = input("Username: ")
        if bool(re.match(r"(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)", usr)) != True:
            print("Email invalid. Please try again.")
        else:
            psw = getpass()
            try:
                server = smtplib.SMTP_SSL('smtp.gmail.com', 465)
                server.login(usr, psw)
                print("Successfully logged in")
                break
            except:
                server.quit()
                counter += 1
                print("Password was incorrect")

    if counter != 5:
        #used to send a test email to make sure user's get an email        
        check = True
        while check == True:
            test = input("Send test email?(yes/no): ")
            if test == 'yes':
                for element in names:
                    message = "Subject: Test\nThis is a test for Secret Santa"
                    email = names[element]['email']
                    server.sendmail(usr, email, message)
                check = False
            elif test == 'no':
                check = False

        #confirms email send
        check = True
        while check == True:
            ready = input("Ready to send emails?(yes/no): ")
            if ready  == 'yes':
                for element in names:
                    message = ''.join(['Subject: Secret Santa!\nYour Secret Santa person is ', names[element]['giftee']])
                    email = names[element]['email']
                    server.sendmail(usr, email, message)
                check = False
            elif ready == 'no':
                check = False
                
        server.quit()
    else:
        clear()
        print("Maximum number of attempts reached")
        input("Press enter to exit")
        clear()
        mainLoop = False

#used to check if giftee's have been generated        
def emailCheck():
    global names
    if names[list(names)[0]]['giftee'] == '':
        print("Secret Santa has not been generated yet.")
        check = True
        while check == True:
            checker = input("Do you wish to continue?(yes/no): ")
            if checker == 'yes':
                check = False
                email()
            elif checker == 'no':
                check = False
    else:
        email()
            

#prints the names dictionary    
def printDict():
    global names
    print(names)

#prints each name and who they give the gift to   
def printSecretSanta():
    global names
    for name in names:
        print("{}: {}".format(name,names[name]['giftee']))
              
#clears screen
def clear(): 
    # for windows 
    if osname == 'nt': 
        system('cls') 
    # for mac and linux(here, os.name is 'posix') 
    else: 
        system('clear')
        
#displays all functions and their string to call them
def helpFunction():
    global func_dict
    for element in func_dict:
        print("{}:{}".format(element,str(func_dict[element])))

#variable containing the reference for each function
func_dict = {'create':createDict,
             'generate':secretSanta,
             'email':emailCheck,
             'dict':printDict,
             'list':printSecretSanta,
             'clear':clear,
             'help':helpFunction}

#main function that starts on code run and takes care of all user input
if __name__ == "__main__":
    clear()
    
    #prints welcome information
    print("Welcome to the Secret Santa Generator")
    print("")
    print("Please enter the following information below:")
    print("Name, Email, Skips")
    print("Please separate skips with a comma")
    print("If no skips, please leave blank")
    print("Type 'done' when finished")
    print('')
    
    welcome = input("Press enter to begin")
    print('')   
    createDict()
    
    clear()
    
    exits = ['bye','done','exit','Exit']
    
    mainLoop = True
    while mainLoop == True:
        print('')
        command = input("> ")
        if command in exits:
            mainLoop = False
        #used to check how well the generate algorithm works
        elif command == 'gen':
            for i in range(1000000):
                secretSanta()
        elif command in func_dict:
            func_dict[command]()
