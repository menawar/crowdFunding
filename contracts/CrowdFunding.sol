  // SPDX-License-Identifier: MIT

pragma solidity 0.8.0;
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
  address payable public owner;
  uint256 public totalCampaigns;
  address internal daiTokenAddress = 0x95b58a6bff3d14b7db2f5cb5f0ad413dc2940658;

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
}