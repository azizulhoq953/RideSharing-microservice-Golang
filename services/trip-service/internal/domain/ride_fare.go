package domain

import "go.mongodb.org/mongo-driver/bson/primitive"

type RideFareModel struct {
	ID                primitive.ObjectID
	UserID            string
	PackageSlug       string
	Amount            float64
	TotalPriceInCents float64
	// ExpiresAt	int64
}
