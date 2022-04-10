pragma solidity >=0.4.21 <0.9.0;

contract ElectionCon {
    address public superAdmin;
    uint256 public electionCount;
    uint256 public voterCount;
    address[] public admins;
    

    constructor() public {
        superAdmin = msg.sender;
        electionCount = 0;
        voterCount = 0;
        admins.push(msg.sender);
    }

    function getAdmin() public view returns (address) {
        return superAdmin;
    }

    modifier onlyAdmin() {
        require(msg.sender == superAdmin);
        _;
    }

    modifier normalAdmin(address _address) {
        bool isAdmin = false;
        for (uint i = 0; i < admins.length; i++) {
            if (_address == admins[i]){
                isAdmin = true;
            }
        }
        require(isAdmin == true);
        _;
    }

    //EMITS
    event EmitAddAdmin(address _admin);

    event EmitVoted(
        address _voter, 
        string _electionTitle, 
        string _candidateName, 
        uint256 _electionCanOneCount, 
        uint256 _electionCanTwoCount,
        uint _timeVoted
    );

    event EmitNewElections(
        uint256 electionId,
        string electionTitle,
        string electionCanOne,
        string electionCanTwo
    );

    event EmitRegisteredVoter(
        uint256 voterId,
        address voterAddress,
        uint256 registeredElection
    );

    event EmitVerifiedVoters(
        uint256 voterId,
        address voterAddress,
        uint256 registeredElection
    );

    event EmitModifiedAccounts(
        address accountAddress,
        string accountName,
        string accountPhone,
        string accountCountry,
        string accountEmail
    );


    //STRUCTS
    struct Election {
        uint256 electionId;
        string electionTitle;
        string electionCanOne;
        string electionCanOneHash;
        uint256 electionCanOneCount;
        string electionCanTwo;
        string electionCanTwoHash;
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
        uint timeVoted;
    }
    mapping(uint256 => Voter) public voterDetails;

    struct Accounts {
        address accountAddress;
        string accountName;
        string accountPhone;
        string accountCountry;
        string accountEmail;
        bool cantChange;
    }
    mapping(address => Accounts) public accountsDetails;

    struct Admins {
        uint256 adminId;
        address adminAddress;
    }
    mapping(uint256 => Admins) public adminDetails;


    //FUNCTIONS FOR ADD
    function addElection(
        string memory _electionTitle,
        string memory _electionCanOne,
        string memory _electionCanTwo,
        string memory _electionCanOneHash,
        string memory _electionCanTwoHash
    ) public onlyAdmin normalAdmin(msg.sender) {
        Election memory newElection =
            Election({
                electionId: electionCount,
                electionTitle: _electionTitle,
                electionCanOne: _electionCanOne,
                electionCanOneHash: _electionCanOneHash,
                electionCanOneCount: 0,
                electionCanTwo: _electionCanTwo,
                electionCanTwoHash: _electionCanTwoHash,
                electionCanTwoCount: 0,
                voterCount: 0,
                votedCount: 0,
                start: false,
                end: false
            });
        electionDetails[electionCount] = newElection;
        electionCount += 1;

        emit EmitNewElections(
            electionCount,
            _electionTitle,
            _electionCanOne,
            _electionCanTwo
        );
    }

    function addVoter(
        uint256 _registeredElection
    ) public {
        require(accountsDetails[msg.sender].cantChange == true);
        require(electionDetails[_registeredElection].start == false && electionDetails[_registeredElection].end == false );
        bool hasRegistered = false;
        for (uint i; i < voterCount; i++) {
            if (voterDetails[i].voterAddress == msg.sender ) {
                if (voterDetails[i].registeredElection == _registeredElection) {
                    hasRegistered = true;
                }
            }
        }
        if (hasRegistered == false) {
            Voter memory newVoter =
                Voter({
                    voterId: voterCount,
                    voterAddress: msg.sender,
                    registeredElection: _registeredElection,
                    isRegistered: true,
                    isVerified: false,
                    hasVoted: false,
                    timeVoted: 0
                });
            voterDetails[voterCount] = newVoter;
            voterCount += 1;

            emit EmitRegisteredVoter(
                voterCount-1,
                voterDetails[voterCount-1].voterAddress,
                _registeredElection
            );
        } else {
            revert();
        }
    }

    function addAccounts(
        string memory _accountName,
        string memory _accountPhone,
        string memory _accountCountry,
        string memory _accountEmail
    ) public {
        require(accountsDetails[msg.sender].cantChange == false);
        Accounts memory newAccount =
            Accounts({
                accountAddress: msg.sender,
                accountName: _accountName,
                accountPhone: _accountPhone,
                accountCountry: _accountCountry,
                accountEmail: _accountEmail,
                cantChange: true
            });
        accountsDetails[msg.sender] = newAccount;

        emit EmitModifiedAccounts(
            accountsDetails[msg.sender].accountAddress,
            _accountName,
            _accountPhone,
            _accountCountry,
            _accountEmail
        );
    }

    function addAdmin(address _adminAddress) public onlyAdmin {
        admins.push(_adminAddress);
        emit EmitAddAdmin(_adminAddress);
    }

    function removeAdmin(uint256 _adminIndex) public {
        delete admins[_adminIndex];
    }


    //FUNCTION FOR VOTES
    function verifyVoter(
        uint256 _voterId,
        uint256 _electionId
    ) public onlyAdmin normalAdmin(msg.sender) {
        /*require that both exists*/
        voterDetails[_voterId].isVerified = true;
        electionDetails[_electionId].voterCount += 1;

        emit EmitVerifiedVoters(
            _voterId,
            voterDetails[_voterId].voterAddress,
            voterDetails[_voterId].registeredElection
        );
    }

    function voteElection(uint256 _voterId, uint256 _electionId, uint256 _candidate) public {
        require(voterDetails[_voterId].hasVoted == false);
        require(voterDetails[_voterId].isVerified == true);
        require(electionDetails[_electionId].start == true);
        require(electionDetails[_electionId].end == false);
        string memory _candidateName;
        if (_candidate == 0) {
            electionDetails[_electionId].electionCanOneCount += 1;
            _candidateName = electionDetails[_electionId].electionCanOne;
        } else if (_candidate == 1) {
            electionDetails[_electionId].electionCanTwoCount += 1;
            _candidateName = electionDetails[_electionId].electionCanTwo;
        } else {}
        electionDetails[_electionId].votedCount += 1;
        voterDetails[_voterId].hasVoted = true;
        voterDetails[_voterId].timeVoted = block.timestamp;

        emit EmitVoted(
            voterDetails[_voterId].voterAddress, 
            electionDetails[_electionId].electionTitle, 
            _candidateName, 
            electionDetails[_electionId].electionCanOneCount, 
            electionDetails[_electionId].electionCanTwoCount,
            voterDetails[_voterId].timeVoted
            );
    }


    //FUNCTION FOR MODIFYING
    function allowChange(address _accountAddress) public onlyAdmin normalAdmin(msg.sender){
        accountsDetails[_accountAddress].cantChange = false;
    }

    
    //FUNCTION FOR ELECTIONS
    function startElection(uint256 _electionId) public onlyAdmin normalAdmin(msg.sender) {
        electionDetails[_electionId].start = true;
        electionDetails[_electionId].end = false;
    }

    function endElection(uint256 _electionId) public onlyAdmin normalAdmin(msg.sender) {
        electionDetails[_electionId].end = true;
        electionDetails[_electionId].start = false;
    }


    //FUNCTION FOR GETS
    function getElectionTitle(uint256 _electionId) public view returns (string memory) {
        return electionDetails[_electionId].electionTitle;
    }
    
    function getVoterName(address _voterAddress) public view returns (string memory) {
        return accountsDetails[_voterAddress].accountName;
    }

    function getAdminLength() public view returns (uint256) {
        return admins.length;
    }

    function getElectionCanOne(uint256 _electionId) public view returns (string memory) {
        return electionDetails[_electionId].electionCanOne;
    }

    function getElectionOneHash(uint256 _electionId) public view returns (string memory) {
        return electionDetails[_electionId].electionCanOneHash;
    }

    function getElectionOneCount(uint256 _electionId) public view returns (uint256) {
        return electionDetails[_electionId].electionCanOneCount;
    }

    function getElectionCanTwo(uint256 _electionId) public view returns (string memory) {
        return electionDetails[_electionId].electionCanTwo;
    }

    function getElectionTwoHash(uint256 _electionId) public view returns (string memory) {
        return electionDetails[_electionId].electionCanTwoHash;
    }

    function getElectionTwoCount(uint256 _electionId) public view returns (uint256) {
        return electionDetails[_electionId].electionCanTwoCount;
    }

    function getVoterAddress(uint256 _voterId) public view returns (address) {
        return voterDetails[_voterId].voterAddress;
    }

    function getVoterRegisteredElection(uint256 _voterId) public view returns (uint256) {
        return voterDetails[_voterId].registeredElection;
    }

    function getIsRegistered(uint256 _voterId) public view returns (bool) {
        return voterDetails[_voterId].isRegistered;
    }

    function getIsVerified(uint256 _voterId) public view returns (bool) {
        return voterDetails[_voterId].isVerified;
    }

    function getHasVoted(uint256 _voterId) public view returns (bool) {
        return voterDetails[_voterId].hasVoted;
    }

    function getTimeVoted(uint256 _voterId) public view returns (uint) {
        return voterDetails[_voterId].timeVoted;
    }

    function getAccountName(address _accountsAddress) public view returns (string memory) {
        return accountsDetails[_accountsAddress].accountName;
    }

    function getAccountPhone(address _accountsAddress) public view returns (string memory) {
        return accountsDetails[_accountsAddress].accountPhone;
    }

    function getAccountCountry(address _accountsAddress) public view returns (string memory) {
        return accountsDetails[_accountsAddress].accountCountry;
    }

    function getAccountEmail(address _accountsAddress) public view returns (string memory) {
        return accountsDetails[_accountsAddress].accountEmail;
    }

    function cantChange(address _accountsAddress) public view returns (bool) {
        return accountsDetails[_accountsAddress].cantChange;
    }

}
