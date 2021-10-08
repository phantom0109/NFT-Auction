// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./TestAuction.sol";
import "./TestSignature.sol";

/**
 * @title Test Auction Factory
 * @dev To do proxy call for Test Auction Contracts
 */
contract TestAuctionFactory is Ownable, IERC721Receiver, TestSignature {
	/*
	*  Storage
	*/
  	bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

	address[] public auctions;
	mapping(uint256 => bool) usedNonces;
	address public Test;

	/*
	*  Events
	*/
	event TestChanged(address Test);
	event SignerChanged(address signer);
	event AuctionStarted(address contractAddress,
						 address sellerAddress,
                         address tokenAddres,
                         uint256 tokenId,
						 uint256 startingPrice,
						 uint256 duration,
                         bool royalty);

	constructor(address _Test, address _signer) {
		Test = _Test;
        _setSigner(_signer);
	}

	/// @dev Returns addresses of auction contracts
	/// @return Returns addresses of auction contracts
	function getAuctions() external view returns (address[] memory) {
		return auctions;
	}

	/// @dev Change address of Test Token(KLO)
	/// @param _Test Address of Test Token(KLO).
	function changeTest(address _Test) external onlyOwner {
		Test = _Test;
		emit TestChanged(Test);
	}

	/// @dev Set the new signer
	/// @param _signer Address of new signer.
	function setSigner(address _signer) external onlyOwner {
		_setSigner(_signer);
		emit SignerChanged(_signer);
	}

    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(address , address , uint256 tokenId, bytes memory _data) override public returns (bytes4) {
        address seller;
        uint256 amount;
        uint256 duration;
        uint256 extra;
        uint256 nonce;
        (seller, amount, duration, extra, nonce) = parseCheck(_data);

		require(!usedNonces[nonce], "Nonce already used");
		require(duration > 0, "Deploying an invalid auction");
		usedNonces[nonce] = true;

        bool royalty = false;
        if (extra == 1) {
            royalty = true;
        }

		TestAuction k = new TestAuction(Test, seller, msg.sender, amount, duration, royalty);
		auctions.push(address(k));
        ERC721 token = ERC721(msg.sender);
        token.approve(address(k), tokenId);
		
		// classic erc721Receiver
		emit AuctionStarted(address(k), seller, msg.sender, tokenId, amount, duration, royalty);

		return _ERC721_RECEIVED;
	}
}
