// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenizedLending {
    // Token definition
    struct StudyMaterial {
        uint256 id;
        string name;
        string description;
        address owner;
        uint256 collateral;
        bool isLent;
    }

    uint256 public materialCount;
    mapping(uint256 => StudyMaterial) public materials;
    mapping(uint256 => address) public borrowers;

    event MaterialListed(uint256 id, string name, address owner, uint256 collateral);
    event MaterialLent(uint256 id, address borrower);
    event MaterialReturned(uint256 id, address borrower);

    // Add a new study material
    function listMaterial(string memory name, string memory description, uint256 collateral) external {
        materialCount++;
        materials[materialCount] = StudyMaterial({
            id: materialCount,
            name: name,
            description: description,
            owner: msg.sender,
            collateral: collateral,
            isLent: false
        });

        emit MaterialListed(materialCount, name, msg.sender, collateral);
    }

    // Borrow a study material
    function borrowMaterial(uint256 id) external payable {
        StudyMaterial storage material = materials[id];
        require(material.id != 0, "Material does not exist");
        require(!material.isLent, "Material is already lent");
        require(msg.value == material.collateral, "Incorrect collateral amount");

        material.isLent = true;
        borrowers[id] = msg.sender;

        emit MaterialLent(id, msg.sender);
    }

    // Return a study material
    function returnMaterial(uint256 id) external {
        require(borrowers[id] == msg.sender, "You are not the borrower");

        StudyMaterial storage material = materials[id];
        material.isLent = false;
        borrowers[id] = address(0);

        payable(msg.sender).transfer(material.collateral);

        emit MaterialReturned(id, msg.sender);
    }
}