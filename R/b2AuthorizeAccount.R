#' Authorise Backblaze B2 Account.
#'
#' \code{b2AuthorizeAccount} authorises an account on Backblaze's B2 cloud
#' storage product.
#'
#' This authorisation function \strong{must be executed first}, before any other
#' functions in this package. Failure to execute \code{b2AuthorizeAccount}
#' renders everything else pointless. You will require a valid Backblaze B2
#' \code{accountId} and \code{authorizationKey}. Create a Backblaze B2 account
#' and obtain your access credentials here:
#'
#' \url{https://www.backblaze.com/b2/cloud-storage.html}
#'
#' Further documentation regarding the Backblaze B2 Cloud Storage API is
#' available here:
#'
#' \url{https://www.backblaze.com/b2/docs/}
#'
#' API account authorization \code{url}, \code{accountId},
#' \code{authorizationKey} are all mandatory and must be user defined.
#'
#' Every time \code{b2AuthorizeAccount} is executed, a new login to Backblaze B2
#' occurs. Don't login more than is necessary.
#'
#' @param url Specific API endpoint address for this function. See examples.
#' @param keyID Account identification code for the relevant Backblaze B2
#'   account. This may be obtained by clicking \emph{Show Account ID and
#'   Application Key} hypertext from the B2 My Account area, after logging in
#'   with a web browser.
#' @param applicationKey Account authorisation key for the relevant Backblaze
#'   B2 account. This may be obtained by clicking \emph{Show Account ID and
#'   Application Key} hypertext from the B2 My Account area, after logging in
#'   with a web browser.
#' @return If successful, an authorisation token, API URL, download URL and your
#'   Account ID will be returned. These are then stored in envrionment
#'   variables. These environment variables will be used in all other functions
#'   in this package. Specific B2 documentation regarding this API call can be
#'   found here:
#'
#'   \url{https://www.backblaze.com/b2/docs/b2_authorize_account.html}
#'
#' @examples
#' \dontrun{
#' b2AuthorizeAccount(url = "https://api.backblaze.com/b2api/v3/b2_authorize_account",
#' accountId = "YourAccountId",
#' authorizationKey = "YourAuthorisationKey")
#' }
#'
#' @export

b2AuthorizeAccount <- function(url, keyID, applicationKey) {
  # Combine Account Id and Authorisation Key
  accessToken <- paste(keyID,":", applicationKey, sep = "")
  # Base 64 encode access token
  accessToken <- openssl::base64_encode(accessToken)
  # GET the data
  b2Return <-
    httr::GET(url = url, httr::add_headers(Authorization = paste("Basic ", accessToken, sep = "")))
  
  # Check for bad authorisation and sent message
  if (httr::status_code(b2Return) != "200") {
    badReturn <-
      jsonlite::fromJSON(httr::content(b2Return,type = "text"))
    stop(
      "Status Code: ", badReturn$code, "\n Message: ", badReturn$message, "\nPlease check your account ID and Authorisation Key. Remember, a new Authorisation key is generated every time you click 'Create application key' in the B2 web interface. \n"
    )
    
  } else {
    # Output as dataframe.
    accountAuthorization <-jsonlite::fromJSON(httr::content(b2Return, type = "text"))
    # Set environment variables to save authorisation details
    Sys.setenv(apiUrl = accountAuthorization$apiInfo$storageApi$apiUrl)
    Sys.setenv(accountId = accountAuthorization$accountId)
    Sys.setenv(authorizationToken = accountAuthorization$authorizationToken)
    Sys.setenv(downloadUrl = accountAuthorization$apiInfo$storageApi$downloadUrl)
  }
}
