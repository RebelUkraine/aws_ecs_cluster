FROM nodered/node-red:latest

# Install additional nodes
RUN npm install node-red-contrib-my-node

# Copy custom flows or settings if needed
COPY flows.json /data/flows.json

# Set user and group
USER node-red

# Expose the port
EXPOSE 1880

# Start Node-RED
CMD ["node-red", "-v"]
