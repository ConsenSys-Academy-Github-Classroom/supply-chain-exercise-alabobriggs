// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

contract SupplyChain {
    // <owner>
    address public owner;

    // <skuCount>
    uint256 public skuCount;

    // <items mapping>
    mapping(uint256 => Item) items;

    // <enum State: ForSale, Sold, Shipped, Received>
    enum State {
        ForSale,
        Sold,
        Shipped,
        Received
    }

    // <struct Item: name, sku, price, state, seller, and buyer>
    struct Item {
        string name;
        uint256 sku;
        uint256 price;
        State state;
        address payable seller;
        address payable buyer;
    }

    /*
     * Events
     */

    // <LogForSale event: sku arg>
    event LogForSale(uint256 sku);

    // <LogSold event: sku arg>
    event LogSold(uint256 sku);

    // <LogShipped event: sku arg>
    event LogShipped(uint256 sku);

    // <LogReceived event: sku arg>
    event LogReceived(uint256 sku);

    /*
     * Modifiers
     */

    // Create a modifer, `isOwner` that checks if the msg.sender is the owner of the contract

    // <modifier: isOwner
    modifier isOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }

    modifier verifyCaller(address _address) {
        require(msg.sender == _address, "Only owner is allowed");
        _;
    }

    modifier paidEnough(uint256 _price) {
        require(msg.value >= _price, "Amount must be above the price");
        _;
    }

    modifier checkValue(uint256 _sku) {
        //refund them after pay for item (why it is before, _ checks for logic before func)
        _;
        uint256 _price = items[_sku].price;
        uint256 amountToRefund = msg.value - _price;
        items[_sku].buyer.transfer(amountToRefund);
    }

    // For each of the following modifiers, use what you learned about modifiers
    // to give them functionality. For example, the forSale modifier should
    // require that the item with the given sku has the state ForSale. Note that
    // the uninitialized Item.State is 0, which is also the index of the ForSale
    // value, so checking that Item.State == ForSale is not sufficient to check
    // that an Item is for sale. Hint: What item properties will be non-zero when
    // an Item has been added?

    // modifier forSale
    modifier forSale(uint256 _sku) {
        require(items[_sku].price > 0, "item is not for sale");
        _;
    }

    // modifier sold(uint _sku)
    modifier sold(uint256 _sku) {
        require(items[_sku].state == State.Sold, "item has been sold");
        _;
    }

    // modifier shipped(uint _sku)
    modifier shipped(uint256 _sku) {
        require(items[_sku].state == State.Shipped, "item has been shipped");
        _;
    }

    // modifier received(uint _sku)
    modifier received(uint256 _sku) {
        require(items[_sku].state == State.Received, "Item has been recieved");
        _;
    }

    constructor() public {
        // 1. Set the owner to the transaction sender
        owner = msg.sender;
        // 2. Initialize the sku count to 0. Question, is this necessary?
        skuCount = 0;
    }

    function addItem(string memory _name, uint256 _price)
        public
        returns (bool)
    {
        // 1. Create a new item and put in array
        // 2. Increment the skuCount by one
        // 3. Emit the appropriate event
        // 4. return true
        // hint:
        items[skuCount] = Item({
            name: _name,
            sku: skuCount,
            price: _price,
            state: State.ForSale,
            seller: msg.sender,
            buyer: address(0)
        });

        skuCount = skuCount + 1;
        emit LogForSale(skuCount);
        return true;
    }

    // Implement this buyItem function.
    // 1. it should be payable in order to receive refunds
    // 2. this should transfer money to the seller,
    // 3. set the buyer as the person who called this transaction,
    // 4. set the state to Sold.
    // 5. this function should use 3 modifiers to check
    //    - if the item is for sale,
    //    - if the buyer paid enough,
    //    - check the value after the function is called to make
    //      sure the buyer is refunded any excess ether sent.
    // 6. call the event associated with this function!
    function buyItem(uint256 _sku)
        public
        payable
        forSale(_sku)
        paidEnough(msg.value)
        checkValue(_sku)
        returns (bool)
    {
        items[_sku].seller.transfer(msg.value);
        items[_sku].buyer = msg.sender;
        items[_sku].state = State.Sold;

        emit LogSold(_sku);
    }

    // 1. Add modifiers to check:
    //    - the item is sold already
    //    - the person calling this function is the seller.
    // 2. Change the state of the item to shipped.
    // 3. call the event associated with this function!
    function shipItem(uint256 _sku) public {}

    // 1. Add modifiers to check
    //    - the item is shipped already
    //    - the person calling this function is the buyer.
    // 2. Change the state of the item to received.
    // 3. Call the event associated with this function!
    function receiveItem(uint256 sku) public {}

    // Uncomment the following code block. it is needed to run tests
    function fetchItem(uint256 _sku)
        public
        view
        returns (
            string memory name,
            uint256 sku,
            uint256 price,
            uint256 state,
            address seller,
            address buyer
        )
    {
        name = items[_sku].name;
        sku = items[_sku].sku;
        price = items[_sku].price;
        state = uint256(items[_sku].state);
        seller = items[_sku].seller;
        buyer = items[_sku].buyer;
        return (name, sku, price, state, seller, buyer);
    }
}
