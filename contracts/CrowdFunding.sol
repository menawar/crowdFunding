// SPDX-License-Identifier: MIT
pragma solidity 0.5.8;
interface IERC20 {
  function transfer(address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function transferFrom(address, address, uint256) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function allowance(address, address) external view returns (uint256);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract CrowdFund {
  address public owner;
  uint256 public totalCampaigns;
  address internal crowdTokenAddress = 0x20C1EB3cAA538954865aD9006bcC8a6f9C1952f3;

    struct Campaign {
        address payable campaignOwner; 
        string campaignTitle; 
        string campaignDescription;
        uint256 goalAmount; 
        uint256 totalAmountFunded;
        uint256 deadline;
        bool goalAchieved;
        bool isCampaignOpen;
        bool isExists; 

        mapping(address => uint256) contributions;
    }

    //stores a Campaign struct for each unique campaign ID.
    mapping(uint256 => Campaign) campaigns;

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyCampaignOwner(uint256 _campaignID) {
        require(msg.sender == campaigns[_campaignID].campaignOwner, "Only Campaign owner can call this function.");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

     function createCampaign(string memory _campaignTitle, string memory _campaignDescription, uint256 _goalAmount, uint256 _fundingPeriodInDays ) public {
        require(bytes(_campaignTitle).length !=0 && bytes(_campaignDescription).length !=0, 'Campaign Title and description cannot be empty!');
        require(_goalAmount > 0, 'Goal amount must be more than 0');
        require(_fundingPeriodInDays >=1 && _fundingPeriodInDays <=7, 'Funding Period should be between 1 -7 days');

        ++totalCampaigns;
        Campaign memory aCampaign = Campaign(msg.sender,_campaignTitle, _campaignDescription, _goalAmount, 0, block.timestamp + (_fundingPeriodInDays * 1 days), false, true, true);
        campaigns[totalCampaigns] = aCampaign;
     }
}