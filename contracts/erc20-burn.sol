pragma solidity ^0.8.6;

import "./interfaces/erc20interface.sol";
import "./safemath.sol";

contract PetroBurn is ERC20Interface, SafeMath {

	mapping (address => uint256) _balances;
	mapping (address => mapping (address => uint256)) _allowed;

	string public _name;
	string public _symbol;
	uint8 public _decimals;
	uint256 public _totalSupply;
	address private _mywallet;

	constructor() {
		_name = "PetroBurn Token";
		_symbol = "PBT";
		_decimals = 18;
		_totalSupply = 1000*10**_decimals;
		_mywallet = msg.sender;
		_balances [_mywallet] = _totalSupply;
		emit Transfer (address(0), _mywallet, _totalSupply);
	} 

	function totalSupply() override public view returns (uint){
		return _totalSupply - _balances[address(0)];
	}

	function balanceOf(address tokenOwner) override public view returns (uint256 balance){
		return _balances[tokenOwner];
	}
	
	function allowance(address owner, address spender)public override view returns(uint256){
		return _allowed[owner][spender];
	}

	function findOnePercent(uint256 value)internal view returns(uint256 result){
		uint256 onePercent = safeDiv(value, 100);
		return onePercent; 
	}

	function transfer(address to, uint256 ammount) override public returns (bool result) {
		
		uint256 toBurn = findOnePercent(ammount);
		uint256 toTransfer = safeSub(ammount, toBurn);

		_balances[msg.sender] = safeSub(_balances[msg.sender], ammount);
		_balances[to] = safeAdd(_balances[to], toTransfer);
		
		_balances[address(0)] = safeAdd(_balances[address(0)], toBurn);

		_totalSupply = safeSub(_totalSupply, toBurn);

		emit Transfer(msg.sender, to, ammount);
		emit Transfer(msg.sender, address(0), toBurn);
		return true; 
	}

	function approve(address spender, uint256 value)override public returns(bool){
		require(spender != address(0));
		_allowed[msg.sender][spender] = value;
		emit Approval(msg.sender, spender, value);
		return true;
	}

	function transferFrom(address from, address to, uint256 value) override public returns (bool result){
		require(to != address(0));
		
		_balances[from] = safeSub(_balances[from], value);

		uint256 toBurn = findOnePercent(value);
		uint256 toTransfer = safeSub(value, toBurn);

		_balances[to] = safeAdd(_balances[to], toTransfer);
		_balances[address(0)] = safeAdd(_balances[address(0)], toBurn);
		_totalSupply = safeSub(_totalSupply, toBurn);

		emit Transfer(from, to, toTransfer);
		emit Transfer(from, address(0), toBurn);
		return true;
	}

	function increaseAllowance(address spender, uint256 value)public returns (bool){
		require(spender != address(0));
		_allowed[msg.sender][spender] = safeAdd(_allowed[msg.sender][spender], value);
		emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
		return true;
	}


	function decreaseAllowance(address spender, uint256 value)public returns (bool){
		require(spender != address(0));
		_allowed[msg.sender][spender] = safeSub(_allowed[msg.sender][spender], value);
		emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
		return true;
	}

	function burn(uint256 ammount) external{
		_burn(msg.sender, ammount);
	}

	function _burn(address account, uint256 ammount) internal{
		_totalSupply = safeSub(_totalSupply, ammount);
		_balances[account] = safeSub(_balances[account], ammount);
		_balances[address(0)] = safeAdd(_balances[address(0)], ammount);
		emit Transfer(account, address(0), ammount);
	}


}