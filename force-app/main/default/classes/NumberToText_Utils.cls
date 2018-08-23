public with sharing class NumberToText_Utils {

    public enum Language { ENGLISH, SPANISH }
    

    /*
		Método que recibe un número decimál y retorna su valor en letras.
		Si se recibe una variable nula se retorna una cadena vacía.
	*/
	public static String getText( decimal decNumber, Language langType, Boolean blnIncludeCents, Boolean blnIncludeCentsAsText, Boolean blnWithCurrencyName, Boolean blnWithCurrenyType )
	{
		String strTexto = '';
		map<integer,tripleta> mapTripletas = new map<integer,tripleta>();
		//Configuración personalizada para definir los valores de cada uno de los números
		map<string,NumberToTextConfiguration__mdt> mapConfiguration = getConfig( langType );
		
		//Se hace la conversión si el valor no es nulo
		if( decNumber != null )
		{
			String strValorEntero = '' + decNumber;
			String strValorEnteroTemp = strValorEntero;
			String strValorDecimal;
			Integer intPosPunto =  strValorEntero.indexOf( '.' );
			Integer intNumAvance = 0;
			Integer intNumTripletas = 0;
			
			//Si el número tiene parte decimal se asignan los valores a las variables correspondientes
			if( intPosPunto != -1 )
			{
				strValorDecimal = strValorEntero.substring( intPosPunto + 1, strValorEntero.length() );
				strValorDecimal = strValorDecimal != null && strValorDecimal.length() > 2 ? strValorDecimal.substring( 0, 2 ) : strValorDecimal;
				strValorEntero = strValorEntero.substring( 0, intPosPunto );
				strValorEnteroTemp = strValorEntero;
			}
			
			//Solo soporta hasta 12 digitos en la traducción entera
			if( strValorEntero.length() > 12 )
				return Label.AVX_NTT_001;
			
			//Obtiene el número de tripletas para llevar el control al momento de generar los textos
			intNumTripletas = strValorEntero.length()/3;
			
			//En caso de tener valor en el residuo se obtiene el número correspondiente
			if( Math.mod( strValorEntero.length(), 3 ) != 0 )
			{
				Integer intValorTemp = Integer.valueOf( strValorEnteroTemp.subString( 0, Math.mod( strValorEntero.length(), 3 ) ) );
				//Si al menos hay 1 residuo se asume como una tripleta adicional
				mapTripletas.put( intNumAvance, new Tripleta( intValorTemp, intNumTripletas + 1, Long.valueOf( strValorEntero ), langType ) );
				strValorEnteroTemp = strValorEnteroTemp.subString( Math.mod( strValorEntero.length(), 3 ) );
				intNumAvance++;
			}
			
			//Se obtienen los valores de las tripletas
			for( integer i = 0; i < ( strValorEntero.length()/3 ); i++ )
			{
				Integer intValorTemp = Integer.valueOf( strValorEnteroTemp.subString( 0, 3 ) );
				mapTripletas.put( intNumAvance, new tripleta( intValorTemp, intNumTripletas, Long.valueOf( strValorEntero ), langType ) );
				strValorEnteroTemp = strValorEnteroTemp.length() > 3 ? strValorEnteroTemp.subString( 3 ) : '';
				intNumAvance++;
				intNumTripletas--;
			}
			
			//Se recorren cada una de las tripletas y se van asignando los valores al resultado final
			for( integer i = 0; i < mapTripletas.keySet().size() ; i++ )
			{
				Tripleta tripletaTemp =  mapTripletas.get( i );
				strTexto += tripletaTemp.centenas.getStrTexto() != '' ? tripletaTemp.centenas.getStrTexto() + ' ' : '';
				strTexto += tripletaTemp.decenas.getStrTexto() != '' ? tripletaTemp.decenas.getStrTexto() + ' ' : '';
				strTexto += tripletaTemp.unidades.getStrTexto() != '' ? tripletaTemp.unidades.getStrTexto() + ' ' : '';
			} 
			
			//Validación de valor cero
			if( strTexto == '' )
				strTexto = mapConfiguration.containsKey( '0' ) ? mapConfiguration.get( '0' ).NumberValue__c + ' ': '';
			
			//Texto final del número antes de los centavos
			if( blnWithCurrencyName ){
				if( decNumber == 1 )
					strTexto += mapConfiguration.containsKey( '$' ) ? mapConfiguration.get( '$' ).NumberValue__c + ' ': '';
				else
					strTexto += mapConfiguration.containsKey( '$' ) ? mapConfiguration.get( '$' ).OptionalValue__c + ' ': '';
			}
			
			//Traducción de los centavos
			if( strValorDecimal != null && blnIncludeCents )
			{
				// no debe tener la palabra antes de los centavos
				strTexto += mapConfiguration.containsKey( 'FINAL' ) ? mapConfiguration.get( 'FINAL' ).NumberValue__c + ' ' : '';
				
				Integer intValorTemp = Integer.valueOf( strValorDecimal );
				if( strValorDecimal.length() == 1 )
					strValorDecimal = '0' + strValorDecimal;
				
				if( !blnIncludeCentsAsText )
					strTexto += strValorDecimal + '/100';
				else{
					tripleta centavos = new tripleta( intValorTemp, 0, Long.valueOf( strValorDecimal ), langType );
					strTexto += centavos.decenas.getStrTexto() != '' ? centavos.decenas.getStrTexto() + ' ' : '';
					strTexto += centavos.unidades.getStrTexto() != '' ? centavos.unidades.getStrTexto() + ' ' : '';
					if( intValorTemp == 1 && strValorDecimal.length() == 2 )
						strTexto += mapConfiguration.containsKey( 'CENTS' ) ? mapConfiguration.get( 'CENTS' ).NumberValue__c + ' ': '';
					else
						strTexto += mapConfiguration.containsKey( 'CENTS' ) ? mapConfiguration.get( 'CENTS' ).OptionalValue__c + ' ': '';
				}
			}
			
			//Tipo de moneda
			strTexto += blnWithCurrenyType && mapConfiguration.containsKey( 'FINAL' ) && mapConfiguration.get( 'FINAL' ).OptionalValue__c != null ? ' ' + mapConfiguration.get( 'FINAL' ).OptionalValue__c : '';
		}
		
		//Mayuscula en la primera letra
		strTexto = strTexto != null && strTexto.length() > 1 ? strTexto.subString( 0, 1 ).toUpperCase() + strTexto.subString( 1 ) : strTexto;
		
		return strTexto;
	}

	private static map<string,NumberToTextConfiguration__mdt> getConfig( Language langType ){
		map<string,NumberToTextConfiguration__mdt> mapReturn = new map<string,NumberToTextConfiguration__mdt>();

		for( NumberToTextConfiguration__mdt config : [	SELECT 	MasterLabel, DeveloperName, Language__c, NumberValue__c, OptionalValue__c 
														FROM 	NumberToTextConfiguration__mdt
														WHERE 	Language__c = :langType.name() ] ){
			mapReturn.put( config.MasterLabel, config );
		}

		return mapReturn;
	}
	
	private class tripleta
	{
		public numero centenas;
		public numero decenas;
		public numero unidades;
		
		public tripleta( integer intValorEvaluar, integer numTripleta, Long intValorInicial, Language langType )
		{
			//Obtiene la configuración de los números
			map<string,NumberToTextConfiguration__mdt> mapConfiguration = getConfig( langType );
			centenas = new numero( intValorEvaluar, 100, null, mapConfiguration, numTripleta, intValorInicial );
			decenas = new numero( intValorEvaluar, 10, centenas, mapConfiguration, numTripleta, intValorInicial );
			unidades = new numero( intValorEvaluar, 1, decenas, mapConfiguration, numTripleta, intValorInicial );
		}
	}
	
	private class numero
	{
		private integer valorEntrada;
		private integer valorTraducir;
		private integer factor;
		private integer valorAcumulado;
		private string strDirecto;
		private string strSegundo;
		private string strTextoFinal;
		
		public numero( Integer intValorEvaluar, integer newFactor, numero numPredecesor, map<string,NumberToTextConfiguration__mdt> mapConfiguration, integer numTripleta, Long intValorInicial )
		{
			factor = newFactor;
			
			//Los valores posibles de factor son 100, 10 y 1
			if( factor == 100 )
				valorEntrada = intValorEvaluar;
			else if( factor == 10 )
				valorEntrada = numPredecesor.getValorEntrada() - numPredecesor.getValorTraducir();
			else if( factor == 1 )
				valorEntrada = numPredecesor.getStrDirecto() != '' ? 0 : numPredecesor.getValorEntrada() - numPredecesor.getValorTraducir();
			
			valorTraducir = Integer.valueOf( valorEntrada / factor ) * factor;
			valorAcumulado = numPredecesor != null ? numPredecesor.getValorAcumulado() : 0;
			valorAcumulado += valorTraducir;
			system.debug( '\n\nFACTOR ' + factor + '\n\nNumTripleta: ' + numTripleta + '\nvalorTraducir: ' + valorTraducir + '\nintValorInicial: ' +intValorInicial + '\nvalorAcumulado: ' + valorAcumulado + '\n\n' );
			//Calcula el valor directo
			if( factor == 100 || factor == 10 )
			{
				if( valorTraducir == 0 )
					strDirecto = '';
				else
					strDirecto = mapConfiguration.containsKey( '' + valorEntrada ) ? mapConfiguration.get( '' + valorEntrada ).NumberValue__c : '';
			}
			else if( factor == 1 )
			{
				strDirecto = numPredecesor.getValorTraducir() > 0 && valorTraducir > 0 ? 'y ' : '';
			}
			
			//Calcula el segundo valor
			if( factor == 100 )
			{
				if( valorTraducir == 0 || strDirecto != '' )
					strSegundo = '';
				else if( mapConfiguration.containsKey( '' + valorTraducir ) )
					strSegundo = valorTraducir == 100 ? mapConfiguration.get( '' + valorTraducir ).OptionalValue__c : mapConfiguration.get( '' + valorTraducir ).NumberValue__c;
			}
			else if( factor == 10 )
			{
				if( valorTraducir == 0 || strDirecto != '' )
					strSegundo = '';
				else
					strSegundo = mapConfiguration.containsKey( '' + valorTraducir ) ? mapConfiguration.get( '' + valorTraducir ).NumberValue__c : '';
			}
			else if( factor == 1 )
			{
				
				if( numTripleta == 0 )//CENTAVOS
				{
					if( valorAcumulado == 0 )
						strSegundo = mapConfiguration.containsKey( '0' ) ? mapConfiguration.get( '0' ).NumberValue__c + ' ': '';
					else
					{
						if( valorTraducir == 0 )
							strSegundo = '';
						else
							strSegundo = mapConfiguration.containsKey( '' + valorTraducir ) ? mapConfiguration.get( '' + valorTraducir ).NumberValue__c : '';
					}
				}
				else if( numTripleta == 1 )
				{
					if( valorTraducir == 0 )
						strSegundo = '';
					else
						strSegundo = mapConfiguration.containsKey( '' + valorTraducir ) ? mapConfiguration.get( '' + valorTraducir ).NumberValue__c : '';
				}
				else if( numTripleta == 2 || numTripleta == 4 )
				{
					if( valorTraducir == 0 )
						strSegundo = '';
					else
						strSegundo = mapConfiguration.containsKey( '' + valorTraducir ) ? mapConfiguration.get( '' + valorTraducir ).NumberValue__c : '';
					
					strSegundo += valorAcumulado > 0 && mapConfiguration.containsKey( '1000' ) ? ' ' + mapConfiguration.get( '1000' ).NumberValue__c : '';
				}
				else if( numTripleta == 3 )
				{
					if( valorTraducir == 0 )
						strSegundo = '';
					else
						strSegundo = mapConfiguration.containsKey( '' + valorTraducir ) ? mapConfiguration.get( '' + valorTraducir ).NumberValue__c : '';
						
					if( String.valueOf( intValorInicial ).length() > 9 || valorAcumulado > 1 )
						strSegundo += mapConfiguration.containsKey( '1000000' ) ? ' ' + mapConfiguration.get( '1000000' ).OptionalValue__c : '';
					else
						strSegundo += mapConfiguration.containsKey( '1000000' ) ? ' ' + mapConfiguration.get( '1000000' ).NumberValue__c : '';
					
					String strValorInicialTemp = String.valueOf( intValorInicial );
					if( strValorInicialTemp.length() > 6 )
					{
						strValorInicialTemp = strValorInicialTemp.subString( strValorInicialTemp.length() - 6, strValorInicialTemp.length() );
						if( Integer.valueOf( strValorInicialTemp ) == 0 )
							strSegundo += ' de ';
					}
				}
			}
			
			//Calcula el texto final
			if( factor == 1 && ( numTripleta == 2 || numTripleta == 4 ) )
					strTextoFinal = valorAcumulado == 1 && mapConfiguration.containsKey( '1000' ) ? ' ' + mapConfiguration.get( '1000' ).NumberValue__c : strDirecto + strSegundo;
			else
				strTextoFinal = strDirecto + strSegundo;
		}
		
		public integer getValorEntrada()
		{
			valorEntrada = valorEntrada == null ? 0 : valorEntrada;
			return valorEntrada;
		}
		
		public integer getValorTraducir()
		{
			valorTraducir = valorTraducir == null ? 0 : valorTraducir;
			return valorTraducir;
		}
		
		public integer getValorAcumulado()
		{
			valorAcumulado = valorAcumulado == null ? 0 : valorAcumulado;
			return valorAcumulado;
		}
		
		public string getStrDirecto()
		{
			strDirecto = strDirecto == null ? '' : strDirecto;
			return strDirecto;
		}
		
		public string getStrSegundo()
		{
			strSegundo = strSegundo == null ? '' : strSegundo;
			return strSegundo;
		}
		
		public string getStrTexto()
		{
			strTextoFinal = strTextoFinal == null ? '' : strTextoFinal;
			return strTextoFinal;
		}
	}
}