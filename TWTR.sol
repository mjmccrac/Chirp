pragma solidity ^0.4.17;

// DO NOT NEED A TOKEN FOR THIS CONTRACT SO DO NOT MAKE ERC-20

contract TWTR {
  // Global
  constructor (){
    TotalNumPosts = 0;
  }

  uint constant MAXCHAR = 128;
  uint constant MAXHASHTAGS = 10;
  uint constant MAXHTLENGTH = 56;

  // Public variables.
  address TWTRId  = msg.sender;
  uint TotalNumPosts;

  // Events that will be fired on changes.
  event TestEvent(string mesg);

  // define a user
  struct User{
    address UserID;
    bool addressIsUsed;
    string TWTRName;
    string [] followers; // having trouble making TWTR[] array - not sure if i can ref type within contract
    string [] following;
    string TwitterLink;  // Post to twitter in parallel / or link this to twitter to mirror what you post there
    string IPFSPhotoLink;  // Link to your user photo on IPFS (ADD LATER)
    uint numUserPosts;
        // Get everything else working first. Deal with IPFS after test posting works
  }
  // define a Post
  struct Post {
	   address author;
     string message;
     bool reTWTR; // retweet?
     string orgTWTR; // original if reTWTR
     bool truncated; //
     uint ID; // Hash of message & author
     //uint Timestamp; // Not needed. We have each post in a block. Can just use block ID
     bytes32[] hashtags;
     string IPFSMediaLink; // I need to put pic into IPFS. Does not start out as link
      // Only 1 media link at first
      // Get everything else working first. Deal with IPFS after test posting works
  }

  mapping(uint256 => Post) public TWTRPosts;      // indexed list of posts
  mapping(address => User) public Users;          // each Eth address = separate User
  mapping(address => uint[]) public UserPostMap;  // for each User's Eth address, provide a list of Post indexes
  mapping(bytes32 => uint[]) public HashTagMap;   // for each possible HashTag, provide a list of related Post indexes

  Post currentPost;
  User newUser;

  function MakeUser (string _Name){ // Can pass address in here as _User alternatively
    // Only 1 user per address so check that address not used yet
    address id = msg.sender;
    if (Users[id].addressIsUsed) revert();
    //User newUser;
    newUser.UserID = id;//_User;
    newUser.TWTRName = _Name;
    newUser.addressIsUsed = true;
    newUser.numUserPosts = 0;
    // Add user to mapping
    Users [id] = newUser;
  }
  function MakePost(string mesg, bytes32[] tags, string IPFSLink, bool _reTWTR, string _orgTWTR) public {
      // Check that User has an account
      address id = msg.sender;
      if (!Users[id].addressIsUsed) revert();

      //Post currentPost;
      // Check that all is OK
      if (bytes(mesg).length > MAXCHAR) revert(); // Message length not too long
      if (tags.length > MAXHASHTAGS) revert(); // Not too many hashtags
      for (uint i = 0; i < tags.length; i++){ // Hashtag lengths not too long
        if (tags[i].length  > MAXHTLENGTH) revert();
      }
      currentPost.author = id;
      currentPost.message = mesg;
      currentPost.hashtags = tags;
      currentPost.reTWTR = _reTWTR;     // if reposting something
      currentPost.orgTWTR = _orgTWTR;   // if reposting, this is the OP
      //currentPost.IPFSMediaLink = null; // deal with this later

      Users[id].numUserPosts++;

        // Add to TWTRPosts Map
        TWTRPosts[TotalNumPosts] = currentPost;
        // Update UserPostMap to reference this post index (currently TotalNumPosts)
        UserPostMap[id].push(TotalNumPosts);
        // Update HashTagMap to reference this post index for each tag
        for (uint j = 0; j < tags.length; j++){
          HashTagMap[tags[j]].push(TotalNumPosts);
        }
      TotalNumPosts ++;
  }


function getNumUserPosts (address TargetUser) public constant returns (uint){
  // validate User
  if (!Users[TargetUser].addressIsUsed) revert();
  if (Users[TargetUser].numUserPosts == 0) revert();
  return UserPostMap[TargetUser].length;
}
function getNumTagPosts (bytes32 TargetTag) public constant returns (uint){
  uint numTag = HashTagMap[TargetTag].length;
  // I think if unused should be zero. if issues, insert code here
  return numTag;
}
function getPostByUser(uint postNum, address TargetUser) public constant returns (string){
  // check valid
  if (!Users[TargetUser].addressIsUsed) revert();
  if (Users[TargetUser].numUserPosts < postNum) revert();
  if (UserPostMap[TargetUser].length < postNum) revert();
  uint postIndex = UserPostMap[TargetUser][postNum];
  return TWTRPosts[postIndex].message; // Later, do some checks to make sure this is valid
}
function getPostByHashtag(uint postNum, bytes32 HTag) public constant returns (string, address){
  if (HashTagMap[HTag].length == 0) revert();
  uint postIndex =  HashTagMap[HTag][postNum];
  return (TWTRPosts[postIndex].message, TWTRPosts[postIndex].author); // Later, do some checks to make sure this is valid
}

function getNameByAddress (address TargetUser) public constant returns (string){
  if (!Users[TargetUser].addressIsUsed) revert();
  return Users[TargetUser].TWTRName;
}

}
