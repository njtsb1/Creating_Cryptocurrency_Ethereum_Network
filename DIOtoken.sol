// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface IERC20 {
    // getters
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    // functions
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract DIOToken is IERC20 {
    string public constant name = "DIO Token";
    string public constant symbol = "DIO";
    uint8 public constant decimals = 18;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowed;

    uint256 private totalSupply_ = 10 ether;

    constructor() {
        balances[msg.sender] = totalSupply_;
        emit Transfer(address(0), msg.sender, totalSupply_);
    }

    // ERC20 getters
    function totalSupply() public view override returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address tokenOwner) public view override returns (uint256) {
        return balances[tokenOwner];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return allowed[owner][spender];
    }

    // transfer tokens to recipient
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount <= balances[msg.sender], "ERC20: transfer amount exceeds balance");

        balances[msg.sender] -= amount;
        balances[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // approve spender
    function approve(address spender, uint256 amount) public override returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");

        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // transfer from owner to buyer using allowance
    function transferFrom(address owner, address buyer, uint256 amount) public override returns (bool) {
        require(owner != address(0), "ERC20: transfer from the zero address");
        require(buyer != address(0), "ERC20: transfer to the zero address");
        require(amount <= balances[owner], "ERC20: transfer amount exceeds balance");
        require(amount <= allowed[owner][msg.sender], "ERC20: transfer amount exceeds allowance");

        balances[owner] -= amount;
        allowed[owner][msg.sender] -= amount;
        balances[buyer] += amount;

        emit Transfer(owner, buyer, amount);
        emit Approval(owner, msg.sender, allowed[owner][msg.sender]); // optional: reflect updated allowance
        return true;
    }

    // convenience functions to mitigate approve race condition
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0), "ERC20: increaseAllowance to the zero address");
        allowed[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0), "ERC20: decreaseAllowance to the zero address");
        uint256 current = allowed[msg.sender][spender];
        require(subtractedValue <= current, "ERC20: decreased allowance below zero");
        allowed[msg.sender][spender] = current - subtractedValue;
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }
}
