// No exemplo abaixo listamos em um array todas as configura��es dispon�veis
user function stampinsdt()
  Local nI, cConfig, aConfig
   
  TCLink()
   
  cConfig := TCConfig( 'ALL_CONFIG_OPTIONS' )
   
  aConfig := StrTokArr( cConfig, ';' )
  For nI := 1 to len( aConfig )
    conout( aConfig[nI] )
  Next
   
  TCUnlink()
return
