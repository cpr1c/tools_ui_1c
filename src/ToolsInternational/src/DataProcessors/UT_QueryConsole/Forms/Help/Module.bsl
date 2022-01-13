
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	Template = FormAttributeToValue("Object").GetTemplate(Parameters.TemplateName);
	Text = Template.GetText();
	Title = Parameters.Title;
EndProcedure
