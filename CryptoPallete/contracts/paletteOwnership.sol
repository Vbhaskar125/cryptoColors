//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import './IERC1155.sol';
import './PaletteBase.sol';
import './IERC1155Metadata_URI.sol';
import './IERC1155Receiver.sol';
import './ERC1155Receiver.sol';

abstract contract paletteOwnership is PaletteBase, IERC1155, IERC1155MetadataURI, ERC1155Receiver{

string public constant name = "CryptoPalette";
string public constant symbol = "CP";


function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }


function balanceOf(address _owner, uint _id) public view returns (uint256){
    return colorToOwner[_id][_owner];
}


function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) public view returns (uint256[] memory){
    require(_owners.length == _ids.length, "Owner and id mismatch");
    uint256[] memory batchBalance = new uint256[](_owners.length);

    for(uint256 i=0; i< _owners.length; i++){
        batchBalance[i] =balanceOf(_owners[i],_ids[i]);
    }

    return batchBalance;
}


function setApprovalForAll(address _operator, bool _approved) public {
    require(msg.sender != _operator, "cannot self approve");

    colorToApproved[msg.sender][_operator]= _approved;
    emit ApprovalForAll(msg.sender,_operator, _approved);
}


function isApprovedForAll(address _owner, address _operator) public view returns (bool){
    return colorToApproved[_owner][_operator];
}

function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) public virtual{
    require(_from == msg.sender || isApprovedForAll(_from,msg.sender), "caller is not owner nor approved");
    _transfer(_from, _to, _id, _value, _data);
     _doSafeAcceptanceCheck(msg.sender,_from, _to, _asSingletonArray(_id), _asSingletonArray(_value), _data);
    
}

function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) public {
    require(_from == msg.sender || isApprovedForAll(_from ,msg.sender), "caller is not owner nor approved");
    
    _safeBatchTransferFrom(_from, _to, _ids, _values, _data);


}



//function to get metadata uri
 function uri(uint256 id) public pure returns (string memory){
     require(id == uint256(uint16(id)));

     if(id < 0x9ff){
         return "ipfs://QmZNFPrHQwZ6sj6biCuuJCREJXvraL8LQqs2SmWNwvCsGV/";
     }else{
         return "ipfs://QmQPSkBDsgW83WEtG5w2HgipKPDQUQQu9tpvDyN5nVAPw8/";
     }
 }


 function _doSafeAcceptanceCheck(address _sender, address _from, address _to, uint256[] memory _ids, uint256[] memory _values, bytes memory _data ) internal {
        if (isContract(_to)) {
                    try IERC1155Receiver(_to).onERC1155BatchReceived(_sender, _from, _ids, _values, _data) returns (
                        bytes4 response
                    ) {
                        if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                            revert("ERC1155: ERC1155Receiver rejected tokens");
                        }
                    } catch Error(string memory reason) {
                        revert(reason);
                    } catch {
                        revert("ERC1155: transfer to non ERC1155Receiver implementer");
                    }
                }

    }

function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (isContract(to)) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response) 
                {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

function _safeBatchTransferFrom(address _from, address _to, uint256[] memory _ids, uint256[] memory _values, bytes memory _data) internal virtual{
    require(_ids.length == _values.length,"id and value mismatch");
    require(address(0) != _to, "to address cannot be 0");
    address  msgsender = msg.sender;
    _beforeTokenTransfer(msgsender, _from, _to, _ids, _values, _data);

    for(uint256 i=0; i<_ids.length; i++){
        uint256 id = _ids[i];
        uint256 amount = _values[i];
        uint256 remBalance =colorToOwner[id][_from];

        require(remBalance >= amount);
        unchecked{
            colorToOwner[id][_from] = remBalance - amount;
        }
        colorToOwner[id][_to] += amount;
    }

    emit TransferBatch(msgsender,_from, _to, _ids, _values);

    _doSafeBatchTransferAcceptanceCheck(msgsender, _from, _to, _ids, _values, _data);
 
}



}
