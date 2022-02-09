//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract PaletteBase {

    event NewColor(uint256 indexed colorId, address indexed owner, uint256 parent1Id, uint256 parent2Id);

    event Transfer(address indexed from, address indexed to, uint256 colorId);

    struct paletteColor{
        uint256 creationTime;
        uint64 coolDownEndBlock;
        uint32 colorId;
        uint32 mixingWithId;
        uint32 parent1ColorId;
        uint32 parent2ColorId;
        uint32 coolDownIndex;
        uint32 generation;
    }

    uint32[14] coolDowns = [
        uint32(1 minutes),
            uint32(2 minutes),
            uint32(5 minutes),
            uint32(10 minutes),
            uint32(30 minutes),
            uint32(1 hours),
            uint32(2 hours),
            uint32(4 hours),
            uint32(8 hours),
            uint32(16 hours),
            uint32(1 days),
            uint32(2 days),
            uint32(4 days),
            uint32(7 days)];

    uint256 secondsPerBlock = 14;

    paletteColor[] colors;

    mapping (uint256 => mapping(address => uint256))  public colorToOwner;

    mapping(address => uint256)  ownedColorCount;

    mapping(address => mapping(address => bool)) public colorToApproved;
    
    //mapping to store array indexes of colorCodes/colorIds
    mapping(uint256 => uint256) internal colorArray;

    //mapping(uint256 => mapping(uint256 => bool)) public allowedToMix;

    mapping(uint256 => uint256) totalSupply;




    function _transfer(address _from, address _to,uint256 _tokenId, uint256 _value, bytes calldata data)internal virtual {
        require(_to != address(0), "transfer to 0 address");
        _beforeTokenTransfer(msg.sender,_from, _to, _asSingletonArray(_tokenId), _asSingletonArray(_value), data);

        uint256 _availableBal =colorToOwner[_tokenId][_from];
        require(_value <= _availableBal);
        unchecked{ colorToOwner[_tokenId][_from] = _availableBal - _value; }
        colorToOwner[_tokenId][_to] += _value;

        emit Transfer(_from, _to, _tokenId);
       
    }


    function _createColor(uint256 _parent1Id, uint256 _parent2Id, uint256 _generation, uint256 _colorId, address _owner) internal virtual returns (bool){
        require(_parent1Id == uint256(uint16(_parent1Id)));
        require(_parent2Id == uint256(uint16(_parent2Id)));
        require(_generation == uint256(uint16(_generation)));
        uint16 coolDownIndex = uint16(_generation /2);

        if(coolDownIndex > 13) coolDownIndex =13;

        paletteColor memory color = paletteColor({
        creationTime: block.timestamp ,
        coolDownEndBlock:  0,
        colorId: uint32(_colorId),
        mixingWithId: 0,
        parent1ColorId : uint32(_parent1Id),
        parent2ColorId : uint32(_parent2Id),
        coolDownIndex :0,
        generation : uint32(_generation)
        });

        colors.push(color);

        emit NewColor(_colorId, _owner, _parent1Id, _parent2Id);

        //_transfer(address(0),_owner, _colorId, 1, data);
        colorArray[_colorId]=(colors.length -1);

        return true ;
    }


    function _asSingletonArray(uint256 element) internal pure virtual returns (uint256[] memory){
        uint256[] memory singArray = new uint256[](1);
        singArray[0] = element;
        return singArray;

    }

    function _beforeTokenTransfer(address _sender, address _from, address _to, uint256[] memory _ids, uint256[] memory _values, bytes memory _data)internal virtual{

    }



}