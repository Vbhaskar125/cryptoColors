
pragma solidity ^0.8.11;
import './colorMixing.sol';

contract cryptoColors is colorMixing{


    function getColor(uint256 _colorId) external view 
    returns (uint256 creationTime,
        uint64 coolDownEndBlock,
        uint32 colorId,
        uint32 mixingWithId,
        uint32 parent1ColorId,
        uint32 parent2ColorId,
        uint32 coolDownIndex,
        uint32 generation)
        {
            paletteColor storage _color =colors[colorArray[_colorId]] ;

            creationTime = _color.creationTime;
            coolDownEndBlock = _color.coolDownEndBlock;
            colorId = _color.colorId;
            mixingWithId = _color.mixingWithId;
            parent1ColorId = _color.parent1ColorId;
            parent2ColorId = _color.parent2ColorId;
            coolDownIndex = _color.coolDownIndex;
            generation = _color.generation;

    } 

}