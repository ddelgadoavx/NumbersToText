public with sharing class NumberToTextTesterController {

	public string strLanguage { get; set; }
	public Decimal decNumValue { get; set; }
	public string strConvertedValue { get; set; }
	public list<SelectOption> lstLanguages { get; set; }
	public Boolean blnIncludeCents { get; set; }
	public Boolean blnWithCurrencyName { get; set; }
	public Boolean blnWithCurrenyType { get; set; }
	public Boolean blnIncludeCentsAsText { get; set; }

    public NumberToTextTesterController() {
    	strLanguage = NumberToText_Utils.Language.SPANISH.name();

    	lstLanguages = new list<SelectOption>();
    	lstLanguages.add( new SelectOption( NumberToText_Utils.Language.SPANISH.name(), NumberToText_Utils.Language.SPANISH.name() ) );
    	lstLanguages.add( new SelectOption( NumberToText_Utils.Language.ENGLISH.name(), NumberToText_Utils.Language.ENGLISH.name() ) );

    	blnIncludeCents = false;
    	blnWithCurrencyName = false;
    	blnWithCurrenyType = false;
    	blnIncludeCentsAsText = false;
    }

    public PageReference doConvertion(){

    	try{
			NumberToText_Utils.Language langType = strLanguage == NumberToText_Utils.Language.SPANISH.name() ? 
														NumberToText_Utils.Language.SPANISH : 
														NumberToText_Utils.Language.ENGLISH;

			strConvertedValue = NumberToText_Utils.getText( decNumValue, langType, blnIncludeCents, blnIncludeCentsAsText, blnWithCurrencyName, blnWithCurrenyType );
		}
		catch( System.exception e ){
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, '' + e.getMessage() ) );
		}

		return null;
    }
}
