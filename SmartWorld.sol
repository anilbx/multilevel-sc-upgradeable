pragma solidity >=0.4.23 <= 0.6.0;
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }
}

contract SmartWorld {
    using SafeMath for uint256;

    struct USER {
        bool joined;
        uint id;
        address payable upline;
        uint personalCount;
        uint256 originalReferrer;
        mapping(uint256 => uint) activeLevel;
    }

    modifier onlyDeployer() {
        require(msg.sender == deployer, "Only Deployer");
        _;
    }
 
    uint public lastIDCount = 0;
    uint public LAST_LEVEL = 6;

    mapping(address => USER) public users;
    mapping(uint256 => uint256) public LevelPrice;

    event Registration(address userAddress, uint256 accountId, uint256 refId, uint side, uint256 _level);
    event BuyLevel(uint256 accountId, uint level);
    event Withdraw(uint256 accountId, uint256 amount);
    
    address public implementation;
    address payable public deployer;
    address payable public owner;
    address payable public admin;
    mapping(uint256 => address payable) public userAddressByID;
    
    constructor(address payable owneraddress, address payable _admin) public {
        owner = owneraddress;
        admin = _admin;
        deployer = msg.sender;

        LevelPrice[1] =  1e18;
        LevelPrice[2] =  2e18;
        LevelPrice[3] =  4e18;
        LevelPrice[4] =  6e18;
        LevelPrice[5] =  8e18;
        LevelPrice[6] =  10e18;
        
        USER memory user;
        lastIDCount++;

        user = USER({joined: true, id: lastIDCount, originalReferrer: 1, personalCount : 0, upline:address(0)});

        users[owneraddress] = user;
        
        userAddressByID[lastIDCount] = owneraddress;

        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[owneraddress].activeLevel[i]++;
        }
    }
    function () payable external {
        address impl = implementation;
        require(impl != address(0));
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, impl, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)
            
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
   function upgradeTo(address _newImplementation) 
        external onlyDeployer 
    {
        require(implementation != _newImplementation);
        _setImplementation(_newImplementation);
    }
    function _setImplementation(address _newImp) internal {
        implementation = _newImp;
    }
    
    function check_slot_status(address userAddress, uint8 _level) public view returns (uint) {
        return users[userAddress].activeLevel[_level];
    }
    
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }
}
