
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	CopyFormData(Parameters.Object, Object);
	
	Title = Parameters.Title;
	Items.Info.Title = Parameters.Info;
	CodeToCopy = Parameters.CodeToCopy;
	FormattedInfo = New FormattedString(Parameters.Info);
	
	Items.CodeToCopy.ChoiceButtonPicture = Items.Copy_Picture.Picture;
	
EndProcedure

