from pathlib import Path
import json
from web3 import Web3
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

class LearnFiAgent:
    def __init__(self):
        # Initialize connection to Sonic testnet
        self.w3 = Web3(Web3.HTTPProvider('https://rpc.blaze.soniclabs.com'))
        
        # Load contract ABI
        contract_path = Path(__file__).parent.parent.parent / 'artifacts' / 'contracts' / 'LearnFi.sol' / 'LearnFiContent.json'
        with open(contract_path) as f:
            contract_data = json.load(f)
            self.contract_abi = contract_data['abi']
        
        # Contract address from your deployment
        self.contract_address = '0x33372a70698c891E686D4FB82798361d4314de96'
        
        # Initialize contract
        self.contract = self.w3.eth.contract(
            address=self.contract_address,
            abi=self.contract_abi
        )
        
        # Set up account
        self.private_key = os.getenv('PRIVATE_KEY')
        self.account = self.w3.eth.account.from_key(self.private_key)
    
    async def generate_educational_content(self, topic):
        """Generate educational content using Claude."""
        prompt = f"""
        Create engaging educational content about {topic} that:
        1. Is suitable for short-form video (under 60 seconds)
        2. Has a clear hook at the beginning
        3. Includes 3 key learning points
        4. Ends with a call to action
        Make it fun and engaging while being educational.
        """
        
        # You'll implement the actual content generation here
        # For now, return a placeholder
        return {
            'title': f'Learn about {topic}',
            'content': 'Educational content placeholder',
            'tags': ['education', topic.lower()]
        }
    
    async def publish_content(self, content):
        """Publish content to the blockchain."""
        try:
            # Build transaction
            nonce = self.w3.eth.get_transaction_count(self.account.address)
            
            # Prepare transaction
            tx = self.contract.functions.createContent(
                content['content'],  # content hash (would be IPFS hash in production)
                0,  # content type (0 for video)
                content['tags']
            ).build_transaction({
                'from': self.account.address,
                'nonce': nonce,
                'gas': 2000000,
                'gasPrice': self.w3.eth.gas_price
            })
            
            # Sign and send transaction
            signed_tx = self.w3.eth.account.sign_transaction(tx, self.private_key)
            tx_hash = self.w3.eth.send_raw_transaction(signed_tx.rawTransaction)
            
            # Wait for transaction receipt
            receipt = self.w3.eth.wait_for_transaction_receipt(tx_hash)
            return receipt
        
        except Exception as e:
            print(f"Error publishing content: {e}")
            return None
    
    async def run(self):
        """Main agent loop."""
        topics = ["Blockchain Basics", "DeFi", "Smart Contracts", "Web3"]
        for topic in topics:
            try:
                # Generate content
                content = await self.generate_educational_content(topic)
                print(f"Generated content for {topic}")
                
                # Publish to blockchain
                receipt = await self.publish_content(content)
                if receipt:
                    print(f"Published content for {topic}. Transaction hash: {receipt['transactionHash'].hex()}")
                
            except Exception as e:
                print(f"Error processing {topic}: {e}")

if __name__ == "__main__":
    import asyncio
    
    agent = LearnFiAgent()
    asyncio.run(agent.run())