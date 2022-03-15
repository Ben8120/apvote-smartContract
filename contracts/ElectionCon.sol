pragma solidity >=0.4.21 <0.9.0;

contract ElectionCon {
    address public superAdmin;
    uint256 electionCount;
    uint256 voterCount;
    uint256 accountsCount;

    constructor() public {
        superAdmin = msg.sender;
        electionCount = 0;
        voterCount = 0;
        accountsCount = 0;
    }

    function getAdmin() public view returns (address) {
        return superAdmin;
    }

    modifier onlyAdmin() {
        require(msg.sender == superAdmin);
        _;
    }

    //EMITS
    /*todo*/


    //STRUCTS
    struct Election {
        uint256 electionId;
        string electionTitle;
        string orgTitle;
        string electionCanOne;
        uint256 electionCanOneCount;
        string electionCanTwo;
        uint256 electionCanTwoCount;
        uint256 voterCount;
        uint256 votedCount;
        bool start;
        bool end;
    }
    mapping(uint256 => Election) public electionDetails;

    struct Voter {
        uint256 voterId;
        address voterAddress;
        uint256 registeredElection;
        bool isRegistered;
        bool isVerified;
        bool hasVoted;
    }
    mapping(uint256 => Voter) public voterDetails;

    struct Accounts {
        uint256 accountId;
        address accountAddress;
        string accountName;
        string accountPhone;
        string accountCountry;
        string accountEmail;
    }
    mapping(address => Accounts) public accountsDetails;


    //FUNCTIONS FOR ADD
    function addElection(
        string memory _electionTitle,
        string memory _orgTitle,
        string memory _electionCanOne,
        string memory _electionCanTwo
    ) public onlyAdmin {
        Election memory newElection =
            Election({
                electionId: electionCount,
                electionTitle: _electionTitle,
                orgTitle: _orgTitle,
                electionCanOne: _electionCanOne,
                electionCanOneCount: 0,
                electionCanTwo: _electionCanTwo,
                electionCanTwoCount: 0,
                voterCount: 0,
                votedCount: 0,
                start: false,
                end: false
            });
        electionDetails[electionCount] = newElection;
        electionCount += 1;
    }

    function addVoter(
        uint256 _registeredElection
    ) public {
        /*require that voter address has name*/
        Voter memory newVoter =
            Voter({
                voterId: voterCount,
                voterAddress: msg.sender,
                registeredElection: _registeredElection,
                isRegistered: true,
                isVerified: false,
                hasVoted: false
            });
        voterDetails[voterCount] = newVoter;
        voterCount += 1;
    }

    function addAccounts(
        string memory _accountName,
        string memory _accountPhone,
        string memory _accountCountry,
        string memory _accountEmail
    ) public {
        Accounts memory newAccount =
            Accounts({
                accountId: accountsCount,
                accountAddress: msg.sender,
                accountName: _accountName,
                accountPhone: _accountPhone,
                accountCountry: _accountCountry,
                accountEmail: _accountEmail
            });
        accountsDetails[msg.sender] = newAccount;
        accountsCount += 1;
    }


    //FUNCTION FOR VOTES
    function verifyVoter(
        uint256 _voterId,
        uint256 _electionId
    ) public onlyAdmin {
        /*require that both exists*/
        voterDetails[_voterId].isVerified = true;
        electionDetails[_electionId].voterCount += 1;
    }

    function voteElection(uint256 _voterId, uint256 _electionId, uint256 _candidate) public {
        require(voterDetails[_voterId].hasVoted == false);
        require(voterDetails[_voterId].isVerified == true);
        require(electionDetails[_electionId].start == true);
        require(electionDetails[_electionId].end == false);
        if (_candidate == 0) {
            electionDetails[_electionId].electionCanOneCount += 1;
        } else if (_candidate == 1) {
            electionDetails[_electionId].electionCanTwoCount += 1;
        } else {}
        electionDetails[_electionId].votedCount += 1;
        voterDetails[_voterId].hasVoted = true;
    }

    
    //FUNCTION FOR ELECTIONS
    function startElection(uint256 _electionId) public onlyAdmin {
        electionDetails[_electionId].start = true;
        electionDetails[_electionId].end = false;
    }

    function endElection(uint256 _electionId) public onlyAdmin {
        electionDetails[_electionId].end = true;
        electionDetails[_electionId].start = false;
    }
}
