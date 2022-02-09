//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
import './paletteOwnership.sol';


contract colorMixing is paletteOwnership{

    //event when a mixing starts
    event MixingColor(address indexed owner, uint256 parent1Id, uint256 parent2Id, uint256 coolDownEndBlock);

    uint256 public mixingFee = 10;
    

    //keeps the count of mixings in progress
    uint256 public mixersDeployed;

    struct Mixer{
        uint256 P1Id;
        uint256 P2Id;
    }

    Mixer[] mixers;


    ///function to get child color code
    function getChildColor(uint256 parent1Id, uint256 parent2Id) internal returns (uint256 ){
        uint32 rno = uint32(block.timestamp % 10) ;
        uint32 childcolorID;

        require(parent1Id >=0 && parent1Id <= 0xfff);
        require(parent2Id >=0 && parent2Id <= 0xfff);

        if(parent1Id > parent2Id){
           childcolorID = uint32(parent1Id - parent2Id);
            childcolorID /= rno;

            childcolorID += uint32(parent2Id);
        }else {
            childcolorID = uint32(parent2Id - parent1Id);
            childcolorID /= rno;

            childcolorID +=uint32(parent1Id);

        }
        while(colorArray[childcolorID] != 0){
            childcolorID++;
        }


        return uint256(childcolorID);
    }

    ///checks the cooldown time is finished and no pending or current mixing is in progress
    function _isReadyToMix(paletteColor memory _color) internal view returns (bool){
        return (uint64(block.number)>=_color.coolDownEndBlock) && (_color.mixingWithId == 0);
    }

    //checks if mixing is possible. owner should own both the colors to mix
    function _isMixingPermitted(uint256 _color1Id, uint256 _color2Id) view internal returns (bool){
        require(colorToOwner[_color1Id][msg.sender] == 1, "need to own the color to mix");
        require(colorToOwner[_color2Id][msg.sender] == 1, "need to own the color to mix");
        return true;
    }

    function _triggerCoolDown(paletteColor storage _color) internal {
        _color.coolDownEndBlock = uint64((coolDowns[_color.coolDownIndex]/secondsPerBlock)+block.number);

        if(_color.coolDownIndex < 13){
            _color.coolDownIndex += 1;
        }
    }
 // both the colors need to finish their cooldown period for mixing to be completed
    function _isMixingCompleted(paletteColor storage  _color , address _owner) internal view returns (bool){
        paletteColor storage color2 = colors[colorArray[_color.mixingWithId]]; //colorToOwner[_color.mixingWithId][_owner];
        return ((_color.mixingWithId != 0) && (_color.coolDownEndBlock<= block.number) && (color2.coolDownEndBlock <= block.number));
    }


    function isReadyToMix(uint256 _colorId) public view returns (bool){
        require(_colorId >= 0);
        uint256 _index= colorArray[_colorId];
        paletteColor storage _color = colors[_index];
        return _isReadyToMix(_color);
    }

    function isMixing(uint256 _colorId) public view returns(bool){
        require(_colorId >= 0);
        uint256 _index = colorArray[_colorId];
        return colors[_index].mixingWithId != 0;
    }

    function _mixWith(uint256 _parent1Id, uint256 _parent2Id) internal {
        paletteColor storage P1 =colors[colorArray[_parent1Id]];
        paletteColor storage P2 =colors[colorArray[_parent2Id]];

        _triggerCoolDown(P1);
        _triggerCoolDown(P2);

        mixersDeployed++;

        uint256 cdeb = (P1.coolDownEndBlock > P2.coolDownEndBlock) ? P1.coolDownEndBlock : P2.coolDownEndBlock ;

        Mixer memory newMixer;
        newMixer.P1Id =P1.colorId;
        newMixer.P2Id = P2.colorId;

        mixers.push(newMixer);

        emit MixingColor(msg.sender, P1.colorId, P2.colorId, cdeb);
        
    }

    function AutoMix(uint256 _parent1Id, uint256 _parent2Id) external payable {
        require(msg.value >= mixingFee);
        //msg.sender must own both the colors
        require(colorToOwner[_parent1Id][msg.sender] >0);
        require(colorToOwner[_parent2Id][msg.sender] >0);

        paletteColor storage P1 =colors[colorArray[_parent1Id]];
        paletteColor storage P2 =colors[colorArray[_parent2Id]];

        require(_isReadyToMix(P1));
        require(_isReadyToMix(P2));

        _mixWith(_parent1Id, _parent2Id);

    }

    function deliverNewColor(uint256 _parentID)external returns(uint256){
        Mixer storage findMixer;
        int j=-1;

        uint256 mixIndex;
        for(uint256 i = 0; i< mixers.length-1  ; i++){
            if((mixers[i].P1Id == _parentID) || (mixers[i].P2Id == _parentID)){
                //findMixer = mixers[i];
                mixIndex =i;
                j=int(i);
                break;
            }

        }

        if(j>=0){
            findMixer = mixers[uint256(j)];
        }else{
            return 0;
        }
        

        require((findMixer.P1Id != 0) && (findMixer.P2Id !=0));

        paletteColor storage P1 =colors[colorArray[findMixer.P1Id]];
        paletteColor storage P2 =colors[colorArray[findMixer.P2Id]];

        require(P1.creationTime !=0);
        require(P2.creationTime !=0);

        require(_isMixingCompleted(P1, msg.sender));

        uint16 parentGen = uint16 ((P1.generation >= P2.generation)? P1.generation : P2.generation);

        uint256 childColorId= getChildColor(P1.colorId,P2.colorId);

        address owner = msg.sender;

        _createColor(P1.colorId, P2.colorId, parentGen+1, childColorId, owner);

        mixersDeployed --;
        delete mixers[mixIndex];

        return childColorId;


    }
    



}