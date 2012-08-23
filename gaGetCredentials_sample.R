#GA OAuth 2.0 authorization script

#save this url/keys etc and place into the proper place in the gaReportScript

library(RCurl)
library(rjson)

client_id = "myclientid.apps.googleusercontent.com" 
client_secret="clientsecret"
redirecturi = ('http://localhost/oauth2callback')
url = paste('https://accounts.google.com/o/oauth2/auth?',
'scope=https://www.googleapis.com/auth/analytics.readonly&',
  'state=%2Fprofile&',
  'redirect_uri=',redirecturi,'&',
  'response_type=code&',
  'client_id=',client_id,'&',
  'approval_prompt=force&',
  'access_type=offline', sep='', collapse='')

getURL(url)
browseURL(url) #give the permissions here with the account you want to give permissions to
#replace code with the code parameter in the URL
browser()

#here's where you paste in the "code" from the resulting url
code = '4/ZOzzcwB2o14flal_h6y7UyPyWaj.8p9cex0LO3kTuJJVnL49Cc_Wvi_8cQI'
opts = list(verbose=T )
accesstoken = fromJSON(postForm('https://accounts.google.com/o/oauth2/token', .opts=opts, code=code, client_id=client_id,
         client_secret=client_secret, redirect_uri=redirecturi, grant_type="authorization_code", 
         style="POST" ))

refresh2accesstoken = function(accesstoken){
  rt = fromJSON(postForm('https://accounts.google.com/o/oauth2/token', .opts=opts,  refresh_token=accesstoken$refresh_token, client_id=client_id,
                                        client_secret=client_secret,  grant_type="refresh_token", 
                                        style="POST" ))
  accesstoken$access_token = rt$access_token
  accesstoken$expires_in = rt$expires_in
  return(accesstoken)
}

#you have a token that allows you to refresh the token for continual access.. but you ahve to refresh it
accesstoken = refresh2accesstoken(accesstoken)

#easiest just to save the token for later
save(accesstoken, file='accesstoken.RData')

#example of retrieving GA data
getURL(paste('https://www.googleapis.com/analytics/v3/management/accounts?access_token=',accesstoken$access_token, sep='', collapse=''))
