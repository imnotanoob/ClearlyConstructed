# ClearlyConstructed
Smart contracts for ClearlyConstructed. We democratize public infrastructure projects by utilizing the blockchain.

Group Members: Anusha Dandamudi, Vikram Baid, Sparsh Jain, Udai Singh, Gilbert Antonious, Sahil Sancheti, and Kaden Dippe. 

# Break Down of Code
Our code is split into three different contracts. The first is a simple project contract, in which you can start a project, fund it, hold money, and in case the project's funding goal doesn't get completed it will be pay back the respective members. We specifically chose to make specific objects public in order to uphold full transparency. The second contract is for Oracles, members of ClearlyConstructed that are involved with approving and changing funding. Each funded project is tied in with a group of 5 oracles, that are all chosen randomly to ensure that budgetting and work is getting done per project basis. The last contract is a simple container contract that ties in the first two contracts together so that it can be called via WEB3 using Metamask.

# Asides
1. Solidity currently does not have a great system to set up PRNG's. After doing research, we chose the best option available using solidity which was seeding using the block hash. 
2. In order to support randomness, we chose to shuffle our arrays of Oracles first, and then simply choosing the first 5 elements from there, as there are no in-built Solidity Libraries in order to randomly choose 5 elements from an array. By shuffling the array randomly using (point #1), and then selecting the first five elements we are esssentially choosing five random elements from the array.
3. We initlialize our container with 5 existing oracles, because we have already identified 5 oracles that will work with us for our project. 5 is the minimum amount, which is why we initialize them. 
