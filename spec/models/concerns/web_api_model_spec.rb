# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WebApiModel do
  describe 'parse_query' do
    example 'number' do
      expect(WebApiModel.parse_query('id:1')).to eq [
        { name: 'id', operator: '=', value: 1, not: false }
      ]
    end

    example 'string' do
      expect(WebApiModel.parse_query('name:"foo"')).to eq [
        { name: 'name', operator: '=', value: 'foo', not: false }
      ]

      expect(WebApiModel.parse_query('name:"foo bar"')).to eq [
        { name: 'name', operator: '=', value: 'foo bar', not: false }
      ]

      expect(WebApiModel.parse_query('name:"foo \"bar\" hoge"')).to eq [
        { name: 'name', operator: '=', value: 'foo "bar" hoge', not: false }
      ]

      expect(WebApiModel.parse_query('updated_at:>"2019-05-15"')).to eq [
        { name: 'updated_at', operator: '>', value: '2019-05-15', not: false }
      ]

      expect(WebApiModel.parse_query('updated_at:>"2019-08-27T18:09:48.073+09:00"')).to eq [
        { name: 'updated_at', operator: '>', value: '2019-08-27T18:09:48.073+09:00', not: false }
      ]
    end

    example 'boolean' do
      expect(WebApiModel.parse_query('foo:true')).to eq [
        { name: 'foo', operator: '=', value: true, not: false }
      ]

      expect(WebApiModel.parse_query('foo:false')).to eq [
        { name: 'foo', operator: '=', value: false, not: false }
      ]
    end

    example 'null' do
      expect(WebApiModel.parse_query('foo:null')).to eq [
        { name: 'foo', operator: '=', value: nil, not: false }
      ]
    end

    example 'ignore invalid value' do
      expect(WebApiModel.parse_query('name:"abc')).to eq []
    end

    example 'operator' do
      expect(WebApiModel.parse_query('id:5')).to eq [
        { name: 'id', operator: '=', value: 5, not: false }
      ]

      expect(WebApiModel.parse_query('id:>5')).to eq [
        { name: 'id', operator: '>', value: 5, not: false }
      ]

      expect(WebApiModel.parse_query('id:>=5')).to eq [
        { name: 'id', operator: '>=', value: 5, not: false }
      ]

      expect(WebApiModel.parse_query('id:<5')).to eq [
        { name: 'id', operator: '<', value: 5, not: false }
      ]

      expect(WebApiModel.parse_query('id:<=5')).to eq [
        { name: 'id', operator: '<=', value: 5, not: false }
      ]
    end

    example 'not' do
      expect(WebApiModel.parse_query('-id:1')).to eq [
        { name: 'id', operator: '=', value: 1, not: true }
      ]
    end

    example 'multiple' do
      expect(WebApiModel.parse_query('name:"foo" id:>5')).to eq [
        { name: 'name', operator: '=', value: 'foo', not: false },
        { name: 'id', operator: '>', value: 5, not: false }
      ]

      expect(WebApiModel.parse_query('name:"foo"　id:>5')).to eq [
        { name: 'name', operator: '=', value: 'foo', not: false },
        { name: 'id', operator: '>', value: 5, not: false }
      ]
    end

    example 'empty' do
      expect(WebApiModel.parse_query('')).to eq []
      expect(WebApiModel.parse_query(' ')).to eq []
      expect(WebApiModel.parse_query(nil)).to eq []
    end
  end

  describe 'parse_order' do
    example 'basic' do
      expect(WebApiModel.parse_order('name')).to eq [
        { sort: 'name', order: 'asc' }
      ]

      expect(WebApiModel.parse_order('-name')).to eq [
        { sort: 'name', order: 'desc' }
      ]
    end

    example 'multiple' do
      expect(WebApiModel.parse_order('name,id')).to eq [
        { sort: 'name', order: 'asc' },
        { sort: 'id', order: 'asc' }
      ]
    end

    example 'empty' do
      expect(WebApiModel.parse_order('')).to eq []
      expect(WebApiModel.parse_order(' ')).to eq []
      expect(WebApiModel.parse_order(nil)).to eq []
    end
  end

  describe 'parse_include' do
    example do
      expect(WebApiModel.parse_include('foo')).to eq [
        {
          foo: {}
        }
      ]

      expect(WebApiModel.parse_include('foo.bar')).to eq [
        {
          foo: {
            bar: {}
          }
        }
      ]

      expect(WebApiModel.parse_include('foo.bar.hoge')).to eq [
        {
          foo: {
            bar: {
              hoge: {}
            }
          }
        }
      ]
    end

    example 'multiple' do
      expect(WebApiModel.parse_include('foo,bar')).to eq [
        {
          foo: {}
        },
        {
          bar: {}
        }
      ]
    end

    example 'empty' do
      expect(WebApiModel.parse_include('')).to eq []
      expect(WebApiModel.parse_include(' ')).to eq []
      expect(WebApiModel.parse_include(nil)).to eq []
    end
  end
end
