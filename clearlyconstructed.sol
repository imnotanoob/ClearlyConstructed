pragma solidity ^0.4.0;

/* Create one simple contract that simply holds money, and holds a mapping of who's paid,
 * as well as the name of the Project. (For now, assume all project names are unique) */

contract SimpleTokenProject {
    /* Name of the project */
    string public name;
    /* Description of the project */
    string public description;
    /* Funding goal for project to go to commence */
    uint public fundingGoal;
    /* Total amount that residents have invested so far */
    uint public totalBalanceSoFar;
    /* Address of the person who initially created this token used to make sure other
     * people on the ethereum network can't transfer, etc. */
    address owner;
    /* This represents someone that has "invested" into a project. */
    struct Purchaser {
        address addressofPurchaser;
        uint totalInvested;
    }
    /* Mapping of address to purchaser i.e. someone who purchased into this bond.
     * Kept as PUBLIC to fit TRANSPARENCY we want to accomplish with our project */
    mapping(address => Purchaser) public investors;
    /* Saved addresses to enable returning money if project does not get sufficient funding */
    address[] public addressofInvestors;
    /* List of oracles chosen randomly for this project */
    Oracle[] public oracles;

    /* Create a new project */
    function SimpleTokenProject(string _name, string _description, uint _fundingGoal, Oracle[] _oracles) {
        name = _name;
        description = _description;
        //Stored as wei's, so make sure to multiply by ether
        fundingGoal = _fundingGoal * 1 ether;
        oracles = _oracles;
        owner = msg.sender;
    }

    /* Revise the name of the project. */
    function changeProjName(string newName) {
        name = newName;
    }

    /* Revise the description of the project. */
    function changeProjDesc(string newDesc) {
        description = newDesc;
    }

    /* Revise the funding necessary for the project. */
    function changeFundingGoal(uint newFundingGoal) {
        fundingGoal = newFundingGoal;
    }

    //Need to make sure the funding goal has not been fully reached. After speaking with
    //the entire team, we realized that we DON'T want extra funds, after oracles have
    //already selected the total amount
    function invest() payable {
        uint investAmount = msg.value;
        address investorAddress = msg.sender;
        // Not >= cuz you don't ever want it to be greater than the amount
        if (fundingGoal == totalBalanceSoFar) {
            revert();
        }
        uint newBalance = totalBalanceSoFar + investAmount;
        //These lines essentially makes sure that our funding goal never exceeds the money
        //sent, and if so it takes the money sent to complete goal and sends back extra.
        if (newBalance > fundingGoal) {
            uint getAmountRemaining = fundingGoal - totalBalanceSoFar;
            uint getAmountoTransferBack = investAmount - getAmountRemaining;
            investAmount = getAmountRemaining;
            investorAddress.transfer(getAmountoTransferBack);
        }
        addressofInvestors.push(investorAddress);
        investors[investorAddress].addressofPurchaser = investorAddress;
        investors[investorAddress].totalInvested += investAmount;
        totalBalanceSoFar += investAmount;
        
    }
    
    //Send back money put in by initial investors, in case the project did not go 
    //through. Require centralized Front-End to call this or hold it, and 
    //put the money in other projects, unless initial investor wants their money back
    //Do this by looping through the entire mapping, and make sure the caller
    //was the owner of the token.
    function sendBack() {
        address sender = msg.sender;
        //Need to do this otherwise huge security problems
        if (owner != sender) {
            throw;
        }
        uint lengthofInvestors = addressofInvestors.length;
        for (uint i=0; i<lengthofInvestors; i++) {
            address singleInvestor = addressofInvestors[i];
            uint investedbyInvestor = investors[singleInvestor].totalInvested;
            singleInvestor.transfer(investedbyInvestor);
        }
        
    }

    /* Retrieves the average funding necessary for project as estimated by 
     * randomly selected group of oracles */
    function approveFunding() {
        uint sum = 0;
        uint numOracles = oracles.length;
        for (uint i = 0; i < numOracles; i += 1) {
            sum += oracles[i].approveFunding(name, description, fundingGoal);
        }
        changeFundingGoal(sum/numOracles);
    }
}

/* Creates an oracle who approves and revises funding */
contract Oracle {
    /* Name of the oracle */
    string public name;
    /* Unique identification number */
    uint public oracleId;

    /* Create a new oracle */
    function Oracle(string _name, uint _id) {
        name = _name;
        oracleId = _id;
    }

    /* Revise funding for project */
    function approveFunding(string projName, string projDesc, uint currFundingGoal) returns (uint){
        return currFundingGoal;
    }
}


/* Create container to hold all projects proposed as well the global oracle list.
 * Five oracles are randomly selected here and assigned to the project upon creation.
 * New oracles that want to participate can be added to the pool here. */
contract Container {
    /* List of all projects proposed */
    SimpleTokenProject[] public allProjects;
    /* Total number of projects */
    uint public numProjects;
    /* All oracles in the pool */
    Oracle[] public allOracles;
    /* Total number of oracles */
    uint public numOracles;
    /* Number of oracles assigned to each project */
    uint public numOraclesPerProj;

    /* Creates a new container with minimum number of necessary oracles */
    function Container() {
        numOracles = 0;
        numOraclesPerProj = 5;
        addOracle("Alice");
        addOracle("Bob");
        addOracle("Carol");
        addOracle("David");
        addOracle("Eve");
        numOracles = 5;
    }
    

    /* Add a project to the project list */
    function addProject(string name, string desc, uint fundingGoal) {
        Oracle[] memory oracleForProj = selectOraclesRandomly();
        allProjects.push(new SimpleTokenProject(name, desc, fundingGoal, oracleForProj));
        numProjects += 1;
    }
    
    /* 
    Shuffle the array to make it random, and then we can select the first 5
    elements, essentially selecting 5 random elements.
    */
    
    function selectOraclesRandomly() returns (Oracle[]){
        Oracle[] tempOracleList;
        Oracle[] returnOracle;
        for (uint z = 0; z < numOracles; z++) {
            Oracle selected = allOracles[z];
            tempOracleList.push(selected);
        }
        for (uint i = numOracles - 1; i > 0; i--) {
            uint j = uint(block.blockhash(block.number-1))%numOracles;
            Oracle temp = tempOracleList[i];
            tempOracleList[i] = tempOracleList[j];
            tempOracleList[j] = temp;

        }
        
        for (uint y = 0; y <  numOraclesPerProj; y++) {
            returnOracle.push(tempOracleList[y]);
        }
        return returnOracle;
    
    }
    
    /* Add an oracle to the pool of oracles */
    function addOracle(string name) {
        allOracles.push(new Oracle(name, numOracles));
        numOracles += 1;
    }
}