pragma solidity 0.4.23;


// a multi-sig wallet based on
// https://github.com/gnosis/MultiSigWallet/blob/master/contracts/MultiSigWallet.sol
// - but reduced to what we need
contract EscrowWallet {
    struct Transaction {
        address destination;
        uint value;
        bytes data;
        bool executed;
    }

    event Confirmation(address indexed sender);
    event Deposit(address indexed sender, uint value);
    event Execution();
    event ExecutionFailure();
    event OwnerAddition(address indexed owner);

    uint constant public MAX_OWNER_COUNT = 5;

    Transaction public transaction;
    address[] public owners;
    mapping (address => bool) public isOwner;
    mapping (address => bool) public confirmations;
    uint public required;

    modifier enoughBalance(uint value) {
        require(value <= this.balance);
        _;
    }

    modifier confirmedBy(address owner) {
        require(confirmations[owner]);
        _;
    }

    modifier notConfirmed(address owner) {
        require(!confirmations[owner]);
        _;
    }

    modifier notExecuted() {
        require(!transaction.executed);
        _;
    }

    modifier onlyWallet() {
        require(msg.sender == address(this));
        _;
    }

    modifier ownerDoesNotExist(address owner) {
        require(!isOwner[owner]);
        _;
    }

    modifier ownerExists(address owner) {
        require(isOwner[owner]);
        _;
    }

    modifier notNull(address _address) {
        require(_address != 0);
        _;
    }

    modifier validRequirement(uint ownerCount, uint _required) {
        require(ownerCount <= MAX_OWNER_COUNT
                && _required <= ownerCount
                && _required != 0
                && ownerCount != 0
        );
        _;
    }

    /// @dev Fallback function allows to deposit ether.
    function()
    public
    payable
    {
        if (msg.value > 0)
            Deposit(msg.sender, msg.value);
    }

    function EscrowWallet(address[] _owners, uint _required)
        public
        validRequirement(_owners.length, _required)
    {
        for (uint i=0; i < _owners.length; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != 0);
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;
    }

    /// @dev Allows to add a new owner. Transaction has to be sent by wallet.
    /// @param owner Address of new owner.
    function addOwner(address owner)
        public
        onlyWallet
        ownerDoesNotExist(owner)
        notNull(owner)
        validRequirement(owners.length + 1, required)
    {
        isOwner[owner] = true;
        owners.push(owner);
        OwnerAddition(owner);
    }

    /// @dev Allows an owner to confirm the transaction.
    function confirmTransaction()
        public
        ownerExists(msg.sender)
        notConfirmed(msg.sender)
    {
        confirmations[msg.sender] = true;
        Confirmation(msg.sender);
        executeTransaction();
    }

    /// @dev Allows anyone to execute a confirmed transaction.
    function executeTransaction()
        public
        ownerExists(msg.sender)
        confirmedBy(msg.sender)
        notExecuted()
        enoughBalance(transaction.value)
    {
        if (isConfirmedByRequired()) {
            transaction.executed = true;
            if (transaction.destination.call.value(transaction.value)(transaction.data))
                Execution();
            else {
                ExecutionFailure();
                transaction.executed = false;
            }
        }
    }

    /// @dev Returns the confirmation status of a transaction.
    /// @return Confirmation status.
    function isConfirmedByRequired()
        public
        constant
        returns (bool)
    {
        uint count = 0;
        for (uint i=0; i < owners.length; i++) {
            if (confirmations[owners[i]])
                count += 1;
            if (count == required)
                return true;
        }
    }

    /// @dev Sets the transaction.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    function setTransaction(address destination, uint value, bytes data)
        internal
        notNull(destination)
    {
        transaction = Transaction({
            destination: destination,
            value: value,
            data: data,
            executed: false
        });
    }

}
