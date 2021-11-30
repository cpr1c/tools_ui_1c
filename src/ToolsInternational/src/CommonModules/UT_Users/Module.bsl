#Region Interface

// Checks whether the current or specified user has full access rights.
// 
// A user is considered to have full access in case of
// a) if the list of infobase users is not empty - 
// 		has the FullRights role and a system administration role (if CheckSystemAdministrationRights = True) 
// b) if the list of infobase users is empty -
//    	has the main configuration role or FullRights 
//
// Parameters:
//  User - Undefined - checks the current IB user.
//               - CatalogRef.Users, CatalogRef.ExternalUsers - searchs for IB user 
//               	  by a unique identifier specified in the attribute IBUserID. 
//               	  If the IB user is not found, returns False.
//               - InfoBaseUser - checks the specified IB user.
//
//  CheckSystemAdministrationRights - Boolean - if True, checks if system administration role is available.
//
//  ConsiderPrivilegedMode - Boolean - if True, returns True for current user if privileged mode is set.
//
// Returning value:
//  Boolean - if True, user have full access rights.
//
Function IsFullUser(User = Undefined, CheckSystemAdministrationRights = False,
	ConsiderPrivilegedMode = True) Export

	Return AccessRight("Administration", Metadata) И AccessRight("DataAdministration", Metadata);
EndFunction

Procedure SetIBUserPassword(UserName, Password) Export
	IBUser=InfoBaseUsers.FindByName(UserName);
	If IBUser=Undefined Then
		Return;
	EndIf;
	
	IBUser.StandardAuthentication=True;
	IBUser.Password=Password;
	IBUser.Write();
EndProcedure

Function StoredIBUserPasswordData(UserName) Export
	IBUser=InfoBaseUsers.FindByName(UserName);
	If IBUser=Undefined Then
		Return Undefined;
	EndIf;
	
	Data=New Structure;
	Data.Insert("StoredPasswordValue", IBUser.StoredPasswordValue);
	Data.Insert("PasswordIsSet", IBUser.PasswordIsSet);
	Data.Insert("StandardAuthentication", IBUser.StandardAuthentication);
	Data.Insert("OSAuthentication", IBUser.OSAuthentication);
	
	Return Data;
EndFunction

Procedure RestoreUserDataAfterUserSessionStart(UserName, StoredIBUserPasswordData) Export
	IBUser=InfoBaseUsers.FindByName(UserName);
	If IBUser=Undefined Then
		Return;
	EndIf;
	
	IBUser.StandardAuthentication=StoredIBUserPasswordData.StandardAuthentication;
	IBUser.StoredPasswordValue=StoredIBUserPasswordData.StoredPasswordValue;
	IBUser.Write();
	
EndProcedure


#EndRegion