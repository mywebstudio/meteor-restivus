@Auth or= {}

###
  A valid user will have exactly one of the following identification fields: id, username, or email
###
userValidator = Match.Where (user) ->
  check user,
    id: Match.Optional String
    username: Match.Optional String
    email: Match.Optional String

  if _.keys(user).length is not 1
    throw new Match.Error 'User must have exactly one identifier field'

  return true

###
  A password can be either in plain text or hashed
###
passwordValidator = Match.OneOf(String,
  digest: String
  algorithm: String)

###
  Return a MongoDB query selector for finding the given user
###
getUserQuerySelector = (user) ->
  if user.id
    return {'_id': user.id}
  else if user.username
    return {'username': user.username}
  else if user.email
    return {'emails.address': user.email}

  # We shouldn't be here if the user object was properly validated
  throw new Error 'Cannot create selector from invalid user'

###
  Log a user in with their password
###
@Auth.loginWithToken = (token) ->
  if not token
    throw new Meteor.Error 401, 'Unauthorized'


  authenticatingUser = Meteor.users.findOne({'services.resume.loginTokens.0.token': token})

  # Add a new auth token to the user's account
  
  hashedToken = Accounts._hashLoginToken token
  Accounts._insertHashedLoginToken authenticatingUser._id, {hashedToken}

  return {authToken: authToken.token, userId: authenticatingUser._id}
