# kvk_app

A new Flutter project.

Flutter version is set to 1.17.5.

## Functionality

### Authentication
An authentication service has been developed to handle all authentication functions.
There are 2 key flows through through the authentication service. signUpWithMobile and logoutUser.

#### signUpWithMobile
There is one key method called by this function which is the verifyPhoneNumber method called on the firebase instance.
This method takes in 6 parameters.
- phoneNumber
- timeout
- verificationCompleted
- verificationFailed
- codeSent
- codeAutoRetrievalTimeout

##### phoneNumber
A String containing the mobile number to be verified

##### timeout
A Duration object which indicates how long the auto-retrieval process should search for

##### verificationCompleted
A function that activates when the auto-retrieval process successfully executes

##### verificationFailed
A function that activates when the verification process fails

##### codeSent
A function that activates each time the verify phone number is sent. This function serves as the manual failsafe

##### codeAutoRetrievalTimeout
A function that activates when the timeout duration is exceeded.

#### logoutUser
The logout user function logs the user out from the firebase instance.

### Database Service
There are 3 core functionality built into the databae service
- Get data
- Update data
- Delete Profile

#### Get Data
The get data functions are split into 4 methods:
- getUserName
- getUserRole
- getUserDesc
- getUserPic

#### Update User
The Update data functionality is one method which takes in a uid and optional parameters. This allows you to update one or more pieces of data related to the user in the one command.
- updateUser

#### Delete User
The Delete data functionality is one method which deletes the user from the data base based on the uid.
- deleteProfile

## Commands
Generate Routes
- flutter packages pub run build_runner clean
- flutter packages pub run build_runner build --delete-conflicting-outputs

Update Package Library
- flutter pub get

Clear Build Cache
- flutter clean

Build Release APK
- flutter build apk