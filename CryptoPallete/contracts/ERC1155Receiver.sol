//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
import './IERC165.sol';
import './ERC165.sol';
import './IERC1155Receiver.sol';

contract ERC1155Receiver is IERC1155Receiver, ERC165 {

    constructor(){
        _registerInterface(
            ERC1155Receiver(address(0)).onERC1155Received.selector ^
            ERC1155Receiver(address(0)).onERC1155BatchReceived.selector
        );
    }

 function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4){
        //return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
        return this.onERC1155Received.selector;
    }


 function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4){
       // return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
        return this.onERC1155BatchReceived.selector;

    }

}


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

