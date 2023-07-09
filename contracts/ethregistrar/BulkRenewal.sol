pragma solidity >=0.8.4;
pragma experimental ABIEncoderV2;

import "../registry/ENS.sol";
import "./ETHRegistrarController.sol";
import "../resolvers/Resolver.sol";

contract BulkRenewal {
    bytes32 constant private ETH_NAMEHASH = 0xd051e4f8cb1870f877b00266e1292322bea4c492a9933488e94d7c1a935e8dfa;
    bytes4 constant private REGISTRAR_CONTROLLER_ID = 0x018fac06;
    bytes4 constant private INTERFACE_META_ID = bytes4(keccak256("supportsInterface(bytes4)"));
    bytes4 constant public BULK_RENEWAL_ID = bytes4(
        keccak256("rentPrice(string[],uint)") ^
        keccak256("renewAll(string[],uint")
    );

    ENS public ens;

    constructor(ENS _ens) public {
        ens = _ens;
    }

    function getController() internal view returns(ETHRegistrarController) {
        Resolver r = Resolver(ens.resolver(ETH_NAMEHASH));
        return ETHRegistrarController(r.interfaceImplementer(ETH_NAMEHASH, REGISTRAR_CONTROLLER_ID));
    }

    function rentPrice(string[] calldata names, uint duration) external view returns(uint total) {
        ETHRegistrarController controller = getController();
        for(uint i = 0; i < names.length; i++) {
            total += controller.rentPrice(names[i], duration);
        }
    }

    function renewAll(string[] calldata names, uint duration) external payable {
        ETHRegistrarController controller = getController();
        for(uint i = 0; i < names.length; i++) {
            uint cost = controller.rentPrice(names[i], duration);
            controller.renew{value:cost}(names[i], duration);
        }
        // Send any excess funds back
        payable(msg.sender).transfer(address(this).balance);
    }

    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {
         return interfaceID == INTERFACE_META_ID || interfaceID == BULK_RENEWAL_ID;
    }
}
