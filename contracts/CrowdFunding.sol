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
  address payable public owner;
  uint256 public totalCampaigns;
   
   address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

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
        require(bytes(_campaignTitle).length != 0 && bytes(_campaignDescription).length != 0, 'Campaign Title and description cannot be empty!');
        require(_goalAmount > 0, 'Goal amount must be more than zero cusd!');
        require(_fundingPeriodInDays >= 1 && _fundingPeriodInDays <= 7, 'Funding Period should be between 1 to 7 days');

        ++totalCampaigns;
        Campaign memory aCampaign = Campaign(msg.sender,_campaignTitle, _campaignDescription, _goalAmount, 0, block.timestamp + (_fundingPeriodInDays * 1 days), false, true, true);
        campaigns[totalCampaigns] = aCampaign;
     }

    function getCampaign(uint _index) public view returns (address payable,
        string memory, 
        string memory,
        uint256,
        uint256,
        uint256,
        bool   
    ) {
        return ( campaigns[_index].campaignOwner,
            campaigns[_index].campaignTitle, 
            campaigns[_index].campaignDescription, 
            campaigns[_index].goalAmount, 
            campaigns[_index].totalAmountFunded,
            campaigns[_index].deadline,
            campaigns[_index].isCampaignOpen
        );
    }

    function fundCampaign(uint256 _campaignID, uint256 _price) public payable {
        
        require(_price > 0, 'You must fund above 0 cusd');
        require(campaigns[_campaignID].isExists,'This project does not exists');
        require(campaigns[_campaignID].isCampaignOpen, 'This project has been closed or ended');
 
        checkCampaignDeadline(_campaignID);
        
         require(
          IERC20(cUsdTokenAddress).transferFrom(
            msg.sender,
             campaigns[_campaignID].campaignOwner,
            _price
           
          ),
          "funding this project has failed."
        );

        campaigns[_campaignID].contributions[msg.sender] = (campaigns[_campaignID].contributions[msg.sender]) + _price;
        campaigns[_campaignID].totalAmountFunded = campaigns[_campaignID].totalAmountFunded + _price;

          //check if funding goal achieved
          if(campaigns[_campaignID].totalAmountFunded >= campaigns[_campaignID].goalAmount){
                    campaigns[_campaignID].goalAchieved = true; 

          }
    }

    function closeCampaign(uint256 _campaignID) public onlyCampaignOwner(_campaignID){
            campaigns[_campaignID].isCampaignOpen = false;

    }

    function getContributions(uint256 _campaignID) public view returns(uint256 contribution){
            require(campaigns[_campaignID].isExists,'Campaign does not exists');

           return campaigns[_campaignID].contributions[msg.sender];

    }

    function checkCampaignDeadline(uint256 _campaignID)  internal {
        
        require(campaigns[_campaignID].isExists,'This p does not exists');
        
        if (now > campaigns[_campaignID].deadline){
            campaigns[_campaignID].isCampaignOpen = false;//Close the campaign
        }

    }
}