// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

/**
 * @title Write a ERC20 contract according to IERC20 from scratch. Don't use library
 * 实现标准接口：
 * - 代币转账
 * - 授权管理
 * - 供应量查询
 */
contract SimpleERC20 {
    string public name;
    string public symbol;
    uint8 public immutable decimals; 
    
    // 总供应量
    uint256 public totalSupply;
    
    // 余额记录
    mapping(address => uint256) private _balances;
    
    // 授权额度记录
    mapping(address => mapping(address => uint256)) private _allowances;

    // 转账事件
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    // 授权事件
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev 构造函数
     * @param _name 代币名称
     * @param _symbol 代币符号
     * @param _decimals 代币精度
     * @param _initialSupply 初始发行量
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        
        _mint(msg.sender, _initialSupply);
    }

    /**
     * @notice 查询账户余额
     * @param account 要查询的地址
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @notice 查询授权额度
     * @param owner 代币所有者
     * @param spender 被授权地址
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @notice 代币转账
     * @param to 接收地址
     * @param value 转账金额
     */
    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0), "ERC20: transfer to zero address");
        
        address owner = msg.sender;
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @notice 授权其他地址使用代币
     * @param spender 被授权地址
     * @param value 授权金额
     */
    function approve(address spender, uint256 value) public returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @notice 从授权账户转账
     * @param from 转出账户
     * @param to 接收账户
     * @param value 转账金额
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }
    
    /**
     * @dev 内部转账实现
     */
    function _transfer(address from, address to, uint256 value) private {
        require(_balances[from] >= value, "ERC20: insufficient balance");
        
        _balances[from] -= value;
        _balances[to] += value;
        
        emit Transfer(from, to, value);
    }

    /**
     * @dev 铸造代币
     */
    function _mint(address to, uint256 value) private {
        require(to != address(0), "ERC20: mint to zero address");
        
        totalSupply += value;
        _balances[to] += value;
        
        emit Transfer(address(0), to, value);
    }

    /**
     * @dev 授权逻辑实现
     */
    function _approve(address owner, address spender, uint256 value) private {
        require(owner != address(0), "ERC20: approve from zero address");
        require(spender != address(0), "ERC20: approve to zero address");
        
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev 消费授权额度时的验证逻辑
     */
    function _spendAllowance(address owner, address spender, uint256 value) private {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= value, "ERC20: insufficient allowance");
            _approve(owner, spender, currentAllowance - value);
        }
    }
}