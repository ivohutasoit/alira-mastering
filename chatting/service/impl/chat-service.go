package impl

import (
	"context"
	"fmt"
	"log"

	"github.com/golang/protobuf/ptypes/empty"
	"github.com/golang/protobuf/ptypes/wrappers"
	domain "github.com/ivohutasoit/alira/common/message/domain"
	service "github.com/ivohutasoit/alira/common/service"
)

// ChatServiceServer is implementation of v1.ChatServiceServer proto interface
type ChatServiceServerImpl struct {
	Message chan string
}

func NewChatServiceServerImpl() service.ChatServiceServer {
	return &ChatServiceServerImpl{Message: make(chan string, 1000)}
}

func (server *ChatServiceServerImpl) Send(ctx context.Context, req *wrappers.StringValue) (*empty.Empty, error) {
	if req != nil {
		log.Printf("Send requested: message %v", *req)
		server.Message <- req.Value
	} else {
		log.Print("Send requested, message <empty>")
	}
	return &empty.Empty{}, nil
}

func (server *ChatServiceServerImpl) Subscribe(req *empty.Empty, srv service.ChatService_SubscribeServer) error {
	log.Print("Subscribe requested")
	for {
		message := <-server.Message
		n := domain.Chat{
			Message: fmt.Sprintf("I have received from you %s. Thanks!", message),
		}
		if err := srv.Send(&n); err != nil {
			server.Message <- message
			log.Printf("Stream connection failed %v", err)
			return nil
		}
		log.Printf("Message sent: %+v", n)
	}
}
