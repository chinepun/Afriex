// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

contract Agency
{
    address owner;

    struct Property
    {
        string propertyName;
        address assignedOwner;
        uint price;
        uint duration;
        uint lastLeaseExpiryTime;
    }
    
    constructor() 
    {
        owner = msg.sender;
    }
    
    mapping(address => Property) public properties;
    mapping(address => uint) accounts;
    Property[] public allProperties; 

    function addProperty(string memory _propertyName, uint _price, uint _duration) public
    {
        require(msg.sender == owner, "You are not the Deployer of the Contract");
        // When a Property Is Added,It Currently has no lease time
        Property memory property = Property(_propertyName, msg.sender, _price, _duration, 0); 
        
        properties[msg.sender].propertyName = _propertyName;
        properties[msg.sender].assignedOwner = msg.sender;
        properties[msg.sender].price = _price;
        properties[msg.sender].duration = _duration;
        properties[msg.sender].lastLeaseExpiryTime = 0;
    
        allProperties.push(property);
    }
    


    function isPropertyFree(Property memory _property) private view returns (bool)
    {
        if ( block.timestamp > _property.lastLeaseExpiryTime)
        {
            return true;
        }else return false;
    }
    
    function setNewOwner(address _newOwner, Property memory _property) private pure
    {
        _property.assignedOwner = _newOwner;
    }
    
    function setLeaseExpiryDate(uint _duration, Property memory _property) private view
    {
        _property.lastLeaseExpiryTime = block.timestamp + _duration * 24 * 60 * 60;
    }
    
    function validatePricePaid(uint _price, uint _duration, Property memory _property) private pure
    {
        require(_property.price == _price * _duration, "The Amount you Deposited Is not Enough For the Time Duration you Selected");
    }
    
    function transfer(address _from, address _to, uint _price) private 
    {
        require(owner == msg.sender, "You are not the Owner of this Contract");
        accounts[_from] -= _price;
        accounts[_to] += _price;
    }
    
    function booking(Property memory _property, address _newOwner, uint _duration, uint _price) public
    {
        require(isPropertyFree(_property), "This property is not Free at the moment");
        validatePricePaid(_price, _duration, _property);
        transfer(_newOwner, owner, _price);
        setNewOwner(_newOwner, _property);
        setLeaseExpiryDate(_duration, _property);
    }
    
}